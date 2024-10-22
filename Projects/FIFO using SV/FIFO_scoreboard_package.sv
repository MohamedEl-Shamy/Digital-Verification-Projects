package FIFO_scoreboard_pkg;
    import FIFO_transcation_pkg::*;
    import shared_package::*;

    class FIFO_scoreboard;
        parameter FIFO_WIDTH = 16;
        parameter FIFO_DEPTH = 8;
        logic [FIFO_WIDTH-1 :0] queue [$];

        logic [FIFO_WIDTH-1:0]  data_out_ref;
        logic full_ref, empty_ref, almostfull_ref, almostempty_ref;
        logic wr_ack_ref, underflow_ref, overflow_ref;
        int counter;

        function void check_data(input FIFO_transaction obj_local);
            //$display("Before the Ref Mod: counter = %0d", counter);
            reference_model(obj_local);
            //$display("After the Ref Mod: counter = %0d", counter);

            if (data_out_ref !== obj_local.data_out || obj_local.full !== full_ref || obj_local.empty !== empty_ref
                || obj_local.almostfull !== almostfull_ref || obj_local.almostempty !== almostempty_ref)begin
                $display("Inputs:");
                $display("data_in = %0b, wr_en = %0b, rd_en = %0b, rst_n = %0b", obj_local.data_in, obj_local.wr_en, obj_local.rd_en, obj_local.rst_n);
                $display("Mismatch detected!\nReference Outputs:");
                $display("data_out_ref = %0b, full_ref = %0b, empty_ref = %0b, almostfull_ref = %0b, almostempty_ref = %0b, wr_ack_ref = %0b, underflow_ref = %0b, overflow_ref = %0b, counter = %0d", 
                          data_out_ref, full_ref, empty_ref, almostfull_ref, almostempty_ref, wr_ack_ref, underflow_ref, overflow_ref, counter); 
                $display("Design Outputs (obj_local):");
                $display("data_out = %0b, full = %0b, empty = %0b, almostfull = %0b, almostempty = %0b, wr_ack = %0b, underflow = %0b, overflow = %0b", 
                        obj_local.data_out, obj_local.full, obj_local.empty, obj_local.almostfull, obj_local.almostempty, obj_local.wr_ack, obj_local.underflow, obj_local.overflow);
                error_count = error_count + 1;
            end 
            else begin
                correct_count = correct_count + 1;
            end

        endfunction

        function void reference_model(FIFO_transaction obj_ref_mod);             
            //Write:
            if (!obj_ref_mod.rst_n) begin
                queue.delete();
                overflow_ref   = 0;
                wr_ack_ref     = 0;   
            end 
            else if (obj_ref_mod.wr_en && !full_ref ) begin
                queue.push_back(obj_ref_mod.data_in);
                wr_ack_ref = 1;
                overflow_ref = 0;
            end
            else begin
                wr_ack_ref = 0;
                if (full_ref && obj_ref_mod.wr_en ) begin
                        overflow_ref = 1;
                end else begin
                        overflow_ref = 0;
                end
            end

            //Read:
            if(!obj_ref_mod.rst_n) begin
                underflow_ref = 0;
            end
            else if (obj_ref_mod.rd_en && !empty_ref) begin
                data_out_ref  = queue.pop_front();
                underflow_ref = 0;
            end
            else begin
                if (empty_ref && obj_ref_mod.rd_en) begin
                    underflow_ref = 1;
                end else begin
                    underflow_ref = 0;
                end
            end

            //Changing Counter:            
            if(!obj_ref_mod.rst_n)begin
                counter = 0;
            end
            else if (({obj_ref_mod.wr_en, obj_ref_mod.rd_en} == 2'b11) && !empty_ref && !full_ref)
			    counter = counter ; 
            else if (({obj_ref_mod.wr_en, obj_ref_mod.rd_en} == 2'b11) && empty_ref)
			    counter = counter + 1; 
			else if (({obj_ref_mod.wr_en, obj_ref_mod.rd_en} == 2'b11) && full_ref)
			    counter = counter - 1; 
			else if	( obj_ref_mod.wr_en && !full_ref) 
			    counter = counter + 1; 
			else if ( obj_ref_mod.rd_en && !empty_ref)
			    counter = counter - 1; 
            else 
                counter = counter; 

            full_ref  = (counter == FIFO_DEPTH)? 1:0;            
            empty_ref = (counter == 0)? 1:0;            
            almostfull_ref  = (counter == FIFO_DEPTH - 1)? 1:0;            
            almostempty_ref = (counter == 1)? 1:0;            
        endfunction
    endclass 
endpackage