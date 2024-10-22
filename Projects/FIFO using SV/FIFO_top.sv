module Top ();
    bit clk;
    always #1 clk = ~clk;

    FIFO_interface inter (clk);
    FIFO DUT (inter);
    FIFO_tb TEST (inter);
    FIFO_monitor_mod MONITOR (inter);        
endmodule