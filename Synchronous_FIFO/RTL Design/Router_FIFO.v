`timescale 1ns/1ps
// Width of FIFO = 8 bits and 16 such data can be stored.
`define W 8
`define D 16

// This module contains the rtl design for the 16x8 FIFO used in the Router
module Synchronous_FIFO_RTL(clk, rstn, w_en, r_en, soft_rst, data_in, lfd_state, flag_empty, flag_full, data_out);
	
	input clk, rstn, w_en, r_en, soft_rst, lfd_state;
	input [`W-1:0] data_in;
	
	output reg [`W-1:0] data_out;
	output flag_empty, flag_full;
	
	//Defining the FIFO Buffer:// Internal Memory: 16 locations, 9 bits wide (8 data + 1 lfd_state)
	reg [`W:0] FIFO_Mem [`D-1:0];
	
	//Defining the read & write pointers for FIFO: 5-bit pointers for 16-deep FIFO (bit [4] is the wrap-around bit)
	reg [4:0] w_ptr;
   reg [4:0] r_ptr;
	reg [6:0] count;
	
	// Flag status
	//--- FLAG LOGIC (Continuous Assignment) ---
   // These are wires, calculated instantly based on pointer values
	assign flag_empty = (w_ptr == r_ptr)?1:0;
	assign flag_full = (w_ptr == {~r_ptr[4], r_ptr[3:0]});

	//--- Block1: FIFO Write Control ---
	always@(posedge clk) begin
	if(!rstn)     w_ptr <= 5'b0;
	else if(soft_rst)   w_ptr <= 5'b0;
	else if(w_en && !flag_full)   w_ptr <= w_ptr + 1;
	end
	
	//--- Block 2: FIFO Read Control ---
	always@(posedge clk) begin
	if(!rstn)	r_ptr <= 0;
	else if(soft_rst)	r_ptr <= 0;
	else if(r_en && !flag_empty)	r_ptr <= r_ptr + 1;
	end
	
	// --- BLOCK 3: Memory Write (Data Path) ---
   // Note: We don't reset the memory array itself to save power/area; 
   // resetting the pointers is enough to "empty" the FIFO.
	always@(posedge clk) begin
	if(w_en && !flag_full)	FIFO_Mem[w_ptr[3:0]] <= {lfd_state, data_in};
	end
	
	// --- BLOCK 4: Data Read Output ---
	always@(posedge clk) begin
	if(!rstn)	data_out <= 8'h00;
	else if(soft_rst)		data_out <= 8'h00;
	else if(r_en && !flag_empty)		data_out <= FIFO_Mem[r_ptr[3:0]][7:0]; // Extract only the 8 data bits
	end
	
	// --- BLOCK 5: Status Counter ---
	always@(posedge clk)	begin
	if(!rstn) count <= 0;
	else if(soft_rst)	count <= 0;
	else begin
	case({(w_en && !flag_full),(r_en && !flag_empty)})
	2'b10: count <= count + 1'b1; // Write only
   2'b01: count <= count - 1'b1; // Read only
   default: count <= count;      // Both or None
	endcase
	end
	end
	endmodule
	
	
