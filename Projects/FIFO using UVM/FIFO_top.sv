import FIFO_test_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

module top ();
    bit clk;
    
    FIFO_if FIFO_if_inst(clk);
    FIFO    DUT (FIFO_if_inst);
    bind FIFO FIFO_SVA FIFO_SVA_inst (FIFO_if_inst);

    initial begin
        forever begin
            #1 clk = ~clk;
        end
    end
    
    initial begin
        uvm_config_db#(virtual FIFO_if)::set(null, "uvm_test_top", "IF_KEY", FIFO_if_inst);
        run_test("FIFO_test");
    end
endmodule