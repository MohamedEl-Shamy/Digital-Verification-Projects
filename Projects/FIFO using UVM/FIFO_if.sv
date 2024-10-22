interface FIFO_if(clk);
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;

    input clk;
    logic [FIFO_WIDTH-1:0] data_in;
    logic rst_n, wr_en, rd_en;

    logic  [FIFO_WIDTH-1:0] data_out;
    logic  wr_ack, overflow, underflow;
    logic  full, empty, almostfull, almostempty;

    modport DUT (
    input clk, data_in, rst_n, wr_en, rd_en,
    output data_out, wr_ack, overflow, underflow,  full, empty, almostfull, almostempty 
    );
endinterface 