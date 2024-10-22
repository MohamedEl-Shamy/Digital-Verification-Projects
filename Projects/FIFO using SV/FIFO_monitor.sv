import FIFO_transcation_pkg::*;
import FIFO_coverage_pkg::*;
import FIFO_scoreboard_pkg::*;
import shared_package::*;

module FIFO_monitor_mod(FIFO_interface.MONITOR inter);
    FIFO_transaction trans_obj = new();
    FIFO_scoreboard  score_obj = new();
    FIFO_coverage    cov_obj   = new();

    initial begin
        forever begin
                @(negedge inter.clk);
                //sample data of interface
                //assign it to var of trans_obj
                trans_obj.data_in     = inter.data_in;  
                trans_obj.rst_n       = inter.rst_n;  
                trans_obj.wr_en       = inter.wr_en; 
                trans_obj.rd_en       = inter.rd_en;

                trans_obj.data_out    = inter.data_out;  
                trans_obj.full        = inter.full;  
                trans_obj.empty       = inter.empty; 
                trans_obj.almostfull  = inter.almostfull;
                trans_obj.almostempty = inter.almostempty;
                trans_obj.wr_ack      = inter.wr_ack;
                trans_obj.underflow   = inter.underflow; 
                trans_obj.overflow    = inter.overflow;

                fork
                    begin
                        cov_obj.sample_data(trans_obj);
                    end

                    begin
                        //@(posedge inter.clk);
                        score_obj.check_data(trans_obj);
                    end
                join

                if (test_finished) begin
                    //display message of corrtect and error counters.
                    $display("Simulation is finished, error count = %0d, correct count = %0d", error_count, correct_count);
                    $stop;
                end
        end
    end  
endmodule