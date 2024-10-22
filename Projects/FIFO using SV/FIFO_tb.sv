import shared_package::*;
import FIFO_transcation_pkg::*;

module FIFO_tb (FIFO_interface.TEST inter);
    enum bit[1:0] {FIFO_0, FIFO_1, FIFO_2, FIFO_3} LABEL;
    FIFO_transaction var_tb = new();

    initial begin
        var_tb.RD_EN_ON_DIST = 20;
        var_tb.WR_EN_ON_DIST = 80;
        //Reset the DUT:
        LABEL = FIFO_0;
        error_count = 0; correct_count = 0;
        inter.rst_n = 0;

        @(negedge inter.clk); 
        #0;
        inter.rst_n = 1;

        LABEL = FIFO_1;
        repeat(1000) begin
            assert(var_tb.randomize());
            inter.data_in = var_tb.data_in;
            inter.wr_en   = var_tb.wr_en;
            inter.rd_en   = var_tb.rd_en;
            inter.rst_n   = var_tb.rst_n;
            
            @(negedge inter.clk); 
            #0;
            // $display("Start");
            // $display("%0b, %0b, %0b, %0b", var_tb.data_in,
            //           var_tb.wr_en,
            //           var_tb.rd_en,
            //           var_tb.rst_n);
            // $display("%0b, %0b, %0b, %0b", inter.data_in,
            //          inter.wr_en,
            //          inter.rd_en,
            //          inter.rst_n);
            // $display("Design Counter = %0d", DUT.count);
            // $display("End");
        end

        var_tb.RD_EN_ON_DIST = 80;
        var_tb.WR_EN_ON_DIST = 20;
        LABEL = FIFO_2;
        repeat(1000) begin
            assert(var_tb.randomize());
            inter.data_in = var_tb.data_in;
            inter.wr_en   = var_tb.wr_en;
            inter.rd_en   = var_tb.rd_en;
            inter.rst_n   = var_tb.rst_n;
            
            @(negedge inter.clk); 
            #0;
        end

        var_tb.RD_EN_ON_DIST = 50;
        var_tb.WR_EN_ON_DIST = 50;
        LABEL = FIFO_3;
        repeat(1000) begin
            assert(var_tb.randomize());
            inter.data_in = var_tb.data_in;
            inter.wr_en   = var_tb.wr_en;
            inter.rd_en   = var_tb.rd_en;
            inter.rst_n   = var_tb.rst_n;
            
            @(negedge inter.clk); 
            #0;
        end

        test_finished = 1;
    end
endmodule