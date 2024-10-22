package FIFO_scoreboard_pkg;
    import FIFO_shared_pkg::*;
    import FIFO_seq_item_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh" 

    class FIFO_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(FIFO_scoreboard)

        uvm_analysis_export   #(FIFO_seq_item) sb_export;
        uvm_tlm_analysis_fifo #(FIFO_seq_item) sb_fifo;
        FIFO_seq_item seq_item_sb;
        
        logic [FIFO_WIDTH-1 :0] queue [$];
        int counter;

        logic [FIFO_WIDTH-1:0]  data_out_ref;
        logic full_ref, empty_ref, almostfull_ref, almostempty_ref;
        logic wr_ack_ref, underflow_ref, overflow_ref;

        int error_count = 0;
        int correct_count = 0;

        function new(string name = "FIFO_scoreboard", uvm_component parent = null);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sb_export = new("sb_export", this);
            sb_fifo   = new("sb_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            sb_export.connect(sb_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                sb_fifo.get(seq_item_sb);
                ref_model(seq_item_sb);
                if(data_out_ref !== seq_item_sb.data_out || seq_item_sb.full !== full_ref || seq_item_sb.empty !== empty_ref
                    || seq_item_sb.almostfull !== almostfull_ref || seq_item_sb.almostempty !== almostempty_ref) begin
                    `uvm_error("run_phase", $sformatf("Comparison failed, Transaction received by the DUT: %s while the data_out_ref: 0b%0b, full_ref: 0b%0b, empty: 0b%0b, almostfull_ref: 0b%0b, almostempty_ref: 0b%0b, wr_ack_ref: 0b%0b, underflow_ref: 0b%0b, overflow_ref: 0b%0b", 
                    seq_item_sb.convert2string(), data_out_ref, full_ref, empty_ref, almostfull_ref, almostempty_ref, wr_ack_ref, underflow_ref, overflow_ref));
                    error_count++;
                end
                else begin
                    `uvm_info("run_phase", $sformatf("Correct FIFO outputs: %s", seq_item_sb.convert2string()), UVM_HIGH);
                    correct_count++;
                end
            end
        endtask

        task ref_model (FIFO_seq_item seq_item_chk);
            //Write:
            if (!seq_item_chk.rst_n) begin
                queue.delete();
                overflow_ref   = 0;
                wr_ack_ref     = 0;   
            end 
            else if (seq_item_chk.wr_en && !full_ref ) begin
                queue.push_back(seq_item_chk.data_in);
                wr_ack_ref = 1;
                overflow_ref = 0;
            end
            else begin
                wr_ack_ref = 0;
                if (full_ref && seq_item_chk.wr_en ) begin
                        overflow_ref = 1;
                end else begin
                        overflow_ref = 0;
                end
            end

            //Read:
            if(!seq_item_chk.rst_n) begin
                underflow_ref = 0;
            end
            else if (seq_item_chk.rd_en && !empty_ref) begin
                data_out_ref  = queue.pop_front();
                underflow_ref = 0;
            end
            else begin
                if (empty_ref && seq_item_chk.rd_en) begin
                    underflow_ref = 1;
                end else begin
                    underflow_ref = 0;
                end
            end

            //Changing Counter:            
            if(!seq_item_chk.rst_n)begin
                counter = 0;
            end
            else if (({seq_item_chk.wr_en, seq_item_chk.rd_en} == 2'b11) && !empty_ref && !full_ref)
			    counter = counter ; 
            else if (({seq_item_chk.wr_en, seq_item_chk.rd_en} == 2'b11) && empty_ref)
			    counter = counter + 1; 
			else if (({seq_item_chk.wr_en, seq_item_chk.rd_en} == 2'b11) && full_ref)
			    counter = counter - 1; 
			else if	( seq_item_chk.wr_en && !full_ref) 
			    counter = counter + 1; 
			else if ( seq_item_chk.rd_en && !empty_ref)
			    counter = counter - 1; 
            else 
                counter = counter; 

            full_ref  = (counter == FIFO_DEPTH)? 1:0;            
            empty_ref = (counter == 0)? 1:0;            
            almostfull_ref  = (counter == FIFO_DEPTH - 1)? 1:0;            
            almostempty_ref = (counter == 1)? 1:0;            
        endtask

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("report_phase", $sformatf("Total successful transactions: %0d", correct_count), UVM_MEDIUM);
            `uvm_info("report_phase", $sformatf("Total failed transactions: %0d", error_count), UVM_MEDIUM);
        endfunction
    endclass
endpackage