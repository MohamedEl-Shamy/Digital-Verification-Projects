package FIFO_shared_pkg;
    enum bit[1:0] {FIFO_0, FIFO_1, FIFO_2, FIFO_3} LABEL;
    
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;

    int RD_EN_ON_DIST = 30;
    int WR_EN_ON_DIST = 70;
endpackage