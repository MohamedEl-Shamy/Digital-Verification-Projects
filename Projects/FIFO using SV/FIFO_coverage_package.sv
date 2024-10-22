package FIFO_coverage_pkg;
    import FIFO_transcation_pkg::*;

    class FIFO_coverage;
        FIFO_transaction F_cvg_txn = new();

        covergroup CrossingInputsOutputs;
            wr_en_cvrpnt: coverpoint F_cvg_txn.wr_en {
                bins High_low_wr_en [2] = {0, 1};
            }
            rd_en_cvrpnt: coverpoint F_cvg_txn.rd_en {
                bins High_low_rd_en [2] = {0, 1};
            }
            wr_ack_cvrpnt: coverpoint F_cvg_txn.wr_ack {
                bins High_low_wr_ack [2] = {0, 1};
            }
            overflow_cvrpnt: coverpoint F_cvg_txn.overflow {
                bins High_low_overflow [2] = {0, 1};
            }
            underflow_cvrpnt: coverpoint F_cvg_txn.underflow {
                bins High_low_underflow [2] = {0, 1};
            }
            full_cvrpnt: coverpoint F_cvg_txn.full {
                bins High_low_full [2] = {0, 1};
            }
            empty_cvrpnt: coverpoint F_cvg_txn.empty {
                bins High_low_empty [2] = {0, 1};
            }
            almostfull_cvrpnt: coverpoint F_cvg_txn.almostfull {
                bins High_low_almostfull [2] = {0, 1};
            }
            almostempty_cvrpnt: coverpoint F_cvg_txn.almostempty {
                bins High_low_almostempty [2] = {0, 1};
            }
            cross_all: cross wr_en_cvrpnt, rd_en_cvrpnt, wr_ack_cvrpnt, overflow_cvrpnt, underflow_cvrpnt, 
                             full_cvrpnt, empty_cvrpnt, almostfull_cvrpnt, almostempty_cvrpnt {
                bins all_combinations = binsof(wr_en_cvrpnt.High_low_wr_en) &&
                                        binsof(rd_en_cvrpnt.High_low_rd_en) &&
                                        binsof(wr_ack_cvrpnt.High_low_wr_ack) &&
                                        binsof(overflow_cvrpnt.High_low_overflow) &&
                                        binsof(underflow_cvrpnt.High_low_underflow) &&
                                        binsof(full_cvrpnt.High_low_full) &&
                                        binsof(empty_cvrpnt.High_low_empty) &&
                                        binsof(almostfull_cvrpnt.High_low_almostfull) &&
                                        binsof(almostempty_cvrpnt.High_low_almostempty);
            }
        endgroup

        function new;
            CrossingInputsOutputs = new();
        endfunction

        function void sample_data (input FIFO_transaction F_txn );
            F_cvg_txn = F_txn;
            CrossingInputsOutputs.sample();
        endfunction
    endclass 
endpackage