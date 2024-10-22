package FIFO_cvg_collector_pkg;
    import FIFO_shared_pkg::*;
    import FIFO_seq_item_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_cvg_collector extends uvm_component;
        `uvm_component_utils(FIFO_cvg_collector)
        uvm_analysis_export   #(FIFO_seq_item) cov_export;
        uvm_tlm_analysis_fifo #(FIFO_seq_item) cov_fifo;
        FIFO_seq_item seq_item_cov;

        covergroup cvr_gp;
            wr_en_cvrpnt: coverpoint seq_item_cov.wr_en {
                bins High_low_wr_en [2] = {0, 1};
            }
            rd_en_cvrpnt: coverpoint seq_item_cov.rd_en {
                bins High_low_rd_en [2] = {0, 1};
            }
            wr_ack_cvrpnt: coverpoint seq_item_cov.wr_ack {
                bins High_low_wr_ack [2] = {0, 1};
            }
            overflow_cvrpnt: coverpoint seq_item_cov.overflow {
                bins High_low_overflow [2] = {0, 1};
            }
            underflow_cvrpnt: coverpoint seq_item_cov.underflow {
                bins High_low_underflow [2] = {0, 1};
            }
            full_cvrpnt: coverpoint seq_item_cov.full {
                bins High_low_full [2] = {0, 1};
            }
            empty_cvrpnt: coverpoint seq_item_cov.empty {
                bins High_low_empty [2] = {0, 1};
            }
            almostfull_cvrpnt: coverpoint seq_item_cov.almostfull {
                bins High_low_almostfull [2] = {0, 1};
            }
            almostempty_cvrpnt: coverpoint seq_item_cov.almostempty {
                bins High_low_almostempty [2] = {0, 1};
            }
            cross_write: cross wr_en_cvrpnt,  almostfull_cvrpnt {}
            cross_read: cross rd_en_cvrpnt, almostempty_cvrpnt{}
            cross_write_overflow: cross wr_en_cvrpnt, full_cvrpnt, overflow_cvrpnt{}
            cross_read_underflow: cross rd_en_cvrpnt, empty_cvrpnt, underflow_cvrpnt{}
            
        endgroup

        function new(string name = "FIFO_cvg_collector", uvm_component parent = null);
            super.new(name, parent);
            cvr_gp = new();
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cov_export = new("cov_export", this);
            cov_fifo   = new("cov_fifo", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            cov_export.connect(cov_fifo.analysis_export);
        endfunction
        
        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                cov_fifo.get(seq_item_cov);
                cvr_gp.sample();
            end
        endtask
    endclass 
endpackage