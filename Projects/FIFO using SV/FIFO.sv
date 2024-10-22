////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(FIFO_interface.DUT inter);
	localparam max_fifo_addr = $clog2(inter.FIFO_DEPTH);

	reg [inter.FIFO_WIDTH-1:0] mem [inter.FIFO_DEPTH-1:0];

	reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
	reg [max_fifo_addr:0] count;

	//Writing Operation:
	always @(posedge inter.clk or negedge inter.rst_n) begin
		if (!inter.rst_n) begin
			wr_ptr <= 0;
			inter.overflow <= 0;
			inter.wr_ack <= 0; 
		end
		else if (inter.wr_en && count < inter.FIFO_DEPTH) begin
			mem[wr_ptr] <= inter.data_in;
			inter.wr_ack <= 1;
			wr_ptr <= wr_ptr + 1;
			inter.overflow <= 0;
		end
		else begin 
			inter.wr_ack <= 0; 
			if (inter.full & inter.wr_en) begin
				inter.overflow <= 1;
			end
			else begin
				inter.overflow <= 0;
			end
		end
	end

	//Reading Operation:
	always @(posedge inter.clk or negedge inter.rst_n) begin
		if (!inter.rst_n) begin
			rd_ptr <= 0;
			inter.underflow <= 0;
		end
		else if (inter.rd_en && count != 0) begin
				inter.data_out <= mem[rd_ptr];
				rd_ptr <= rd_ptr + 1;
				inter.underflow <= 0;
			end
		else begin
			if (inter.empty & inter.rd_en) begin
				inter.underflow <= 1;
			end else begin
				inter.underflow <= 0;
			end		
		end
	end

	//Changing the counter:
	always @(posedge inter.clk or negedge inter.rst_n) begin
		if (!inter.rst_n) begin
			count <= 0;
		end
		else begin
			if (({inter.wr_en, inter.rd_en} == 2'b11) && !inter.empty && !inter.full)
				count <= count ;
			else if (({inter.wr_en, inter.rd_en} == 2'b11) && inter.empty)
				count <= count + 1;
			else if (({inter.wr_en, inter.rd_en} == 2'b11) && inter.full)
				count <= count - 1;
			else if	( inter.wr_en && !inter.full) 
				count = count + 1;
			else if ( inter.rd_en && !inter.empty)
				count = count - 1;
		end
	end

	assign inter.full = (count == inter.FIFO_DEPTH)? 1 : 0;
	assign inter.empty = (count == 0)? 1 : 0;
	assign inter.almostfull = (count == inter.FIFO_DEPTH-1)? 1 : 0; 
	assign inter.almostempty = (count == 1)? 1 : 0;

	`ifdef SIM
		always_comb begin
			if (!inter.rst_n) begin
				async_reset: assert final (count == 0 && wr_ptr == 0 && rd_ptr == 0);
			end
		end
		always_comb begin
			if (inter.rst_n) begin
				if (count == inter.FIFO_DEPTH) begin
					OnFull: assert final (inter.full == 1);
				end
				if (count == 0) begin
					OnEmpty: assert final (inter.empty == 1);
				end
				if (count == inter.FIFO_DEPTH - 1) begin
					OnAlmostFull: assert final (inter.almostfull == 1);
				end
				if (count == 1) begin
					OnAlmostEmpty: assert final (inter.almostempty == 1);
				end
			end
		end

		property OnOverflow;
			@(posedge inter.clk) disable iff(!inter.rst_n) 
			(inter.full && inter.wr_en && !inter.rd_en) |=> (inter.overflow);
		endproperty
		property OnUnderflow;
			@(posedge inter.clk) disable iff(!inter.rst_n) 
			(inter.empty && inter.rd_en && !inter.wr_en) |=> (inter.underflow);
		endproperty
		property OnWriteAcknowledge;
			@(posedge inter.clk) disable iff(!inter.rst_n) 
			(inter.wr_en && !inter.rd_en && !inter.full) |=> (count == $past(count) + 1);
		endproperty
		property OnWritePointer;
			@(posedge inter.clk) disable iff(!inter.rst_n) 
			(inter.wr_en && !inter.full && !inter.rd_en) |=> (wr_ptr == ($past(wr_ptr) + 1) % inter.FIFO_DEPTH);
		endproperty
		property OnReadPointer;
			@(posedge inter.clk) disable iff(!inter.rst_n) 
			(inter.rd_en && !inter.empty && !inter.full) |=> (rd_ptr == ($past(rd_ptr) + 1) % inter.FIFO_DEPTH);
		endproperty
		
		assert property(OnOverflow) 		else $display("old overflow = %0b, overflow = %0b", $past(inter.overflow), inter.overflow);
		assert property(OnUnderflow) 		else $display("old underflow= %0b, underflow= %0b", $past(inter.underflow), inter.underflow);
		assert property(OnWriteAcknowledge);
		assert property(OnWritePointer)		else $display("old write pointer = %0d, write pointer = %0d",$past(wr_ptr), wr_ptr);
		assert property(OnReadPointer) 		else $display("old rd pointer = %0d, rd pointer = %0d", 	$past(rd_ptr), rd_ptr);
		
		cover property(OnOverflow);
		cover property(OnUnderflow);
		cover property(OnWriteAcknowledge);
		cover property(OnWritePointer);
		cover property(OnReadPointer);
		
	`endif 
endmodule