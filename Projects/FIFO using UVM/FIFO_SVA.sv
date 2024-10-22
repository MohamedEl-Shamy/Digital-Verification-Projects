import FIFO_shared_pkg::*;
module FIFO_SVA(FIFO_if.DUT FIFO_if_inst);

		always_comb begin
			if (FIFO_if_inst.rst_n) begin
				if (DUT.count == FIFO_if_inst.FIFO_DEPTH) begin
					OnFull: assert final (!FIFO_if_inst.empty && FIFO_if_inst.full && !FIFO_if_inst.almostfull && !FIFO_if_inst.almostempty);
				end
				if (DUT.count == 0) begin
					OnEmpty: assert final (FIFO_if_inst.empty && !FIFO_if_inst.full && !FIFO_if_inst.almostfull && !FIFO_if_inst.almostempty);
				end
				if (DUT.count == FIFO_if_inst.FIFO_DEPTH - 1) begin
					OnAlmostFull: assert final (!FIFO_if_inst.empty && !FIFO_if_inst.full && FIFO_if_inst.almostfull && !FIFO_if_inst.almostempty);
				end
				if (DUT.count == 1) begin
					OnAlmostEmpty: assert final (!FIFO_if_inst.empty && !FIFO_if_inst.full && !FIFO_if_inst.almostfull && FIFO_if_inst.almostempty);
				end
			end
		end

        property Sync_reset;
            @(posedge FIFO_if_inst.clk) (!FIFO_if_inst.rst_n) |=> (DUT.count == 0 && DUT.wr_ptr == 0 && DUT.rd_ptr == 0)
        endproperty

        //Remove all disables of rst, as it is synch now.
		property OnOverflow;
			@(posedge FIFO_if_inst.clk) disable iff (!FIFO_if_inst.rst_n) 
			(FIFO_if_inst.full && FIFO_if_inst.wr_en && !FIFO_if_inst.rd_en) |=> (FIFO_if_inst.overflow);
		endproperty
		property OnUnderflow;
			@(posedge FIFO_if_inst.clk) disable iff (!FIFO_if_inst.rst_n) 
			(FIFO_if_inst.empty && FIFO_if_inst.rd_en && !FIFO_if_inst.wr_en) |=> (FIFO_if_inst.underflow);
		endproperty
		property OnWriteAcknowledge;
			@(posedge FIFO_if_inst.clk) disable iff (!FIFO_if_inst.rst_n) 
			(FIFO_if_inst.wr_en && !FIFO_if_inst.rd_en && !FIFO_if_inst.full) |=> (DUT.count == $past(DUT.count) + 1);
		endproperty
		property OnWritePoFIFO_if_inst;
			@(posedge FIFO_if_inst.clk) disable iff (!FIFO_if_inst.rst_n) 
			(FIFO_if_inst.wr_en && !FIFO_if_inst.full && !FIFO_if_inst.rd_en) |=> (DUT.wr_ptr == ($past(DUT.wr_ptr) + 1) % FIFO_if_inst.FIFO_DEPTH);
		endproperty
		property OnReadPoFIFO_if_inst;
			@(posedge FIFO_if_inst.clk) disable iff (!FIFO_if_inst.rst_n) 
			(FIFO_if_inst.rd_en && !FIFO_if_inst.empty && !FIFO_if_inst.full) |=> (DUT.rd_ptr == ($past(DUT.rd_ptr) + 1) % FIFO_if_inst.FIFO_DEPTH);
		endproperty
		

        assert property (Sync_reset);
		assert property(OnOverflow) 		else $display("old overflow = %0b, overflow = %0b", $past(FIFO_if_inst.overflow), FIFO_if_inst.overflow);
		assert property(OnUnderflow) 		else $display("old underflow= %0b, underflow= %0b", $past(FIFO_if_inst.underflow), FIFO_if_inst.underflow);
		assert property(OnWriteAcknowledge);
		assert property(OnWritePoFIFO_if_inst)		else $display("old write poFIFO_if_inst = %0d, write poFIFO_if_inst = %0d",$past(DUT.wr_ptr), DUT.wr_ptr);
		assert property(OnReadPoFIFO_if_inst) 		else $display("old rd poFIFO_if_inst = %0d, rd poFIFO_if_inst = %0d", 	$past(DUT.rd_ptr), DUT.rd_ptr);
		
        cover property (Sync_reset);
		cover property(OnOverflow);
		cover property(OnUnderflow);
		cover property(OnWriteAcknowledge);
		cover property(OnWritePoFIFO_if_inst);
		cover property(OnReadPoFIFO_if_inst);
		
endmodule