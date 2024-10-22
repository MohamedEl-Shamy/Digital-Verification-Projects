package FIFO_rw_sqnc_pkg;
    import FIFO_seq_item_pkg::*;
    import FIFO_shared_pkg::*;
    import uvm_pkg ::*;
    `include "uvm_macros.svh"

    class FIFO_rw_sqnc extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_rw_sqnc)
        FIFO_seq_item seq_item;

        function new(string name = "FIFO_rw_sqnc");
            super.new(name);
        endfunction 

        virtual task body();
            //Read and Write with the same distributions
            RD_EN_ON_DIST = 50;
            WR_EN_ON_DIST = 50;

            repeat(1000) begin
               seq_item = FIFO_seq_item::type_id::create("seq_item");
                start_item(seq_item);
                assert(seq_item.randomize());
                finish_item(seq_item); 
            end
        endtask
    endclass 
endpackage