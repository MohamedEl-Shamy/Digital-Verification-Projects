////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO (FIFO_if.DUT FIFO_if_inst);

	localparam max_fifo_addr = $clog2(FIFO_if_inst.FIFO_DEPTH);

	reg [FIFO_if_inst.FIFO_WIDTH-1:0] mem [FIFO_if_inst.FIFO_DEPTH-1:0];

	reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
	reg [max_fifo_addr:0] count;

	//Writing Operation:
	always @(posedge FIFO_if_inst.clk) begin
		if (!FIFO_if_inst.rst_n) begin
			wr_ptr <= 0;
			FIFO_if_inst.overflow <= 0;
			FIFO_if_inst.wr_ack <= 0; 
		end
		else if (FIFO_if_inst.wr_en && count < FIFO_if_inst.FIFO_DEPTH) begin
			mem[wr_ptr] <= FIFO_if_inst.data_in;
			FIFO_if_inst.wr_ack <= 1;
			wr_ptr <= wr_ptr + 1;
			FIFO_if_inst.overflow <= 0;
		end
		else begin 
			FIFO_if_inst.wr_ack <= 0; 
			if (FIFO_if_inst.full & FIFO_if_inst.wr_en) begin
				FIFO_if_inst.overflow <= 1;
			end
			else begin
				FIFO_if_inst.overflow <= 0;
			end
		end
	end

	//Reading Operation:
	always @(posedge FIFO_if_inst.clk) begin
		if (!FIFO_if_inst.rst_n) begin
			rd_ptr <= 0;
			FIFO_if_inst.underflow <= 0;
		end
		else if (FIFO_if_inst.rd_en && count != 0) begin
				FIFO_if_inst.data_out <= mem[rd_ptr];
				rd_ptr <= rd_ptr + 1;
				FIFO_if_inst.underflow <= 0;
			end
		else begin
			if (FIFO_if_inst.empty & FIFO_if_inst.rd_en) begin
				FIFO_if_inst.underflow <= 1;
			end else begin
				FIFO_if_inst.underflow <= 0;
			end		
		end
	end

	//Changing the counter:
	always @(posedge FIFO_if_inst.clk) begin
		if (!FIFO_if_inst.rst_n) begin
			count <= 0;
		end
		else begin
			if (({FIFO_if_inst.wr_en, FIFO_if_inst.rd_en} == 2'b11) && !FIFO_if_inst.empty && !FIFO_if_inst.full)
				count <= count ;
			else if (({FIFO_if_inst.wr_en, FIFO_if_inst.rd_en} == 2'b11) && FIFO_if_inst.empty)
				count <= count + 1;
			else if (({FIFO_if_inst.wr_en, FIFO_if_inst.rd_en} == 2'b11) && FIFO_if_inst.full)
				count <= count - 1;
			else if	( FIFO_if_inst.wr_en && !FIFO_if_inst.full) 
				count = count + 1;
			else if ( FIFO_if_inst.rd_en && !FIFO_if_inst.empty)
				count = count - 1;
		end
	end

	assign FIFO_if_inst.full = (count == FIFO_if_inst.FIFO_DEPTH)? 1 : 0;
	assign FIFO_if_inst.empty = (count == 0)? 1 : 0;
	assign FIFO_if_inst.almostfull = (count == FIFO_if_inst.FIFO_DEPTH-1)? 1 : 0; 
	assign FIFO_if_inst.almostempty = (count == 1)? 1 : 0;
endmodule