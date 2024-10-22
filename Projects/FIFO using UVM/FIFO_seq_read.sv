package FIFO_read_sqnc_pkg;
    import FIFO_seq_item_pkg::*;
    import FIFO_shared_pkg::*;
    import uvm_pkg ::*;
    `include "uvm_macros.svh"

    class FIFO_read_sqnc extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_read_sqnc)
        FIFO_seq_item seq_item;

        function new(string name = "FIFO_read_sqnc");
            super.new(name);
        endfunction 

        virtual task body();
            //read more
            RD_EN_ON_DIST = 20;
            WR_EN_ON_DIST = 80;

            repeat(1000) begin
               seq_item = FIFO_seq_item::type_id::create("seq_item");
                start_item(seq_item);
                assert(seq_item.randomize());
                finish_item(seq_item); 
            end
        endtask
    endclass 
endpackage