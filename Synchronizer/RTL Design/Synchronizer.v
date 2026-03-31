// This RTL Design is for synchroniser which synchronises the FIFO and the Router Controller.

`timescale 1ns/1ps

module Synchronizer_RTL(clk, rstn, detectAdd, dataIn, w_en_reg, flagFull0, flagFull1, flagFull2, flagEm0, flagEm1, flagEm2, r_en0, r_en1, r_en2, validOut0, validOut1, validOut2, fifoFull, soft_rst0, soft_rst1, soft_rst2, w_en);

	input clk, rstn, detectAdd, w_en_reg, flagFull0, flagFull1, flagFull2, flagEm0, flagEm1, flagEm2, r_en0, r_en1, r_en2;
	input [1:0] dataIn;
	
	output validOut0, validOut1, validOut2; 
	output reg fifoFull; 
	output reg soft_rst0, soft_rst1, soft_rst2;
	output reg [2:0] w_en; // one hot encoding for the 3 FIFOs.
	
	// To store the dataIn value 
	reg [1:0] addr;
	// To keep idle cycle count for soft reset
	reg [4:0] cntIdle0;
	reg [4:0] cntIdle1;
	reg [4:0] cntIdle2;
	
	// When the fifo is not empty a valid output signal is generated:
	assign validOut0 = ! flagEm0;
	assign validOut1 = ! flagEm1;
	assign validOut2 = ! flagEm2;
	// This assignment allows the synchronizer to control over the read operation of the FIFOs. The flag signal is coming from the FSM controller.
	
	
	//Storing the address to internal register for routing the data to one FIFO:
	always@(posedge clk)	begin
	if(detectAdd == 1)
	addr <= 2'b11;
	else if (detectAdd)
	addr <= dataIn;
	end
	
	//As per address of the FIFO detected, write enable is activated for that FIFO:
	always@(*)	begin
	if(! w_en_reg) // This signal comes from the controller to enable write operation for FIFOs
	w_en = 3'b000; // This disables the write operation
	else begin
	case(addr) 
	2'b00 : w_en = 3'b001;  // FIFO 1 write
	2'b01 : w_en = 3'b010;  // FIFO 2 write
	2'b10 : w_en = 3'b100;	// FIFO 3 write
	default: w_en = 3'b000;
	endcase
	end
	end
	
	// SOFT RESET LOGIC: FIFO 1
	always@(posedge clk)	begin
	//Hard reset: No data is written in the FIFO so no read operation required and no idle cyxle cnt is valid
	if(~rstn) begin
	cntIdle0<=0;
	soft_rst0<=0;
	end
	//The FIFO is already being Read, so no need for idle cycle cnt. and so no soft reset is required. 
	//Also if there is not valid output signal, read is not required and so no idle count is required.
	else if(r_en0 || ~validOut0) begin
	cntIdle0<=0;
	soft_rst0<=0;
	end
	// When the read is supposed to happen but not taking place:
	else if (cntIdle0 == 5'd30) begin
	soft_rst0<=1;
	cntIdle0<=0;
	end
	else begin
	cntIdle0 <= cntIdle0 + 1;
	soft_rst0 <=0;
	end
	end
	
	// SOFT RESET LOGIC: FIFO 2
	always@(posedge clk)	begin
	//Hard reset: No data is written in the FIFO so no read operation required and no idle cyxle cnt is valid
	if(~rstn) begin
	cntIdle1<=0;
	soft_rst1<=0;
	end
	//The FIFO is already being Read, so no need for idle cycle cnt. and so no soft reset is required. 
	//Also if there is not valid output signal, read is not required and so no idle count is required.
	else if(r_en1 || ~validOut1) begin
	cntIdle1<=0;
	soft_rst1<=0;
	end
	// When the read is supposed to happen but not taking place:
	else if (cntIdle0 == 5'd30) begin
	soft_rst1<=1;
	cntIdle1<=0;
	end
	else begin
	cntIdle1 <= cntIdle1 + 1;
	soft_rst1 <=0;
	end
	end
	
	// SOFT RESET LOGIC: FIFO 3
	always@(posedge clk)	begin
	//Hard reset: No data is written in the FIFO so no read operation required and no idle cyxle cnt is valid
	if(~rstn) begin
	cntIdle2<=0;
	soft_rst2<=0;
	end
	//The FIFO is already being Read, so no need for idle cycle cnt. and so no soft reset is required. 
	//Also if there is not valid output signal, read is not required and so no idle count is required.
	else if(r_en2 || ~validOut2) begin
	cntIdle2<=0;
	soft_rst2<=0;
	end
	// When the read is supposed to happen but not taking place:
	else if (cntIdle2 == 5'd30) begin
	soft_rst2<=1;
	cntIdle2<=0;
	end
	else begin
	cntIdle2 <= cntIdle2 + 1;
	soft_rst2 <=0;
	end
	end
	
	// This is the signal that tells the main Router FSM: "Hey, the destination the user picked is full, stop sending data!"
	// Fifo Full MUX logic:
	always@(*)	begin
	case(addr)
	2'b00: fifoFull = flagFull0;
	2'b01: fifoFull = flagFull1;
	2'b10: fifoFull = flagFull2;
	default: fifoFull = 0;
	endcase
	end
	endmodule
	
	
