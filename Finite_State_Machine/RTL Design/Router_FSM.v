// MOORE FSM used for controlling the signals in the router:
// There are 8 states across which the FSM transitions:
`define DecodeAddress 3'b000
`define LoadFirstData 3'b001
`define LoadData 3'b010
`define LoadParity 3'b011
`define FIFO_FullState 3'b100
`define LoadAfterFull 3'b101
`define WaitTillEmpty 3'b110
`define CheckParity 3'b111

module FSM_RTL(
//input ports
input clk,
input rstn,
input soft_rst0,
input soft_rst1,
input soft_rst2,
input flagEm0,
input flagEm1,
input flagEm2,
input flagFull,
input pktValid,
input lowPktValid,
input parityDone,
input [1:0] dataIn,

//output ports
output busy,
output detectAdd,
output w_en_reg,
output ldState,
output lafState,
output lfdState,
output fullState,
output rst_int_reg
);

// iNTERNAL REGISTERS FOR SEQ. LOGIC

reg [2:0] nextState;
reg [1:0] tempData;
reg [2:0] presentState;

// Temporarily storing the address data
always@(posedge clk)	begin
if(detectAdd)
tempData <= dataIn;
end

// PRESENT STATE LOGIC:
always@(posedge clk)	begin
//default state: DecodeAddress
if(!rstn)
presentState <= `DecodeAddress;
else if(tempData == 2'b00 & soft_rst0)
presentState <= `DecodeAddress;
else if(tempData == 2'b01 & soft_rst1)
presentState <= `DecodeAddress;
else if(tempData == 2'b10 & soft_rst2)
presentState <= `DecodeAddress;
else
presentState <= nextState;
end

//NEXT STATE LOGIC: STATE TRANSIITON
always@(*)	begin
//start with DecodeAddress
nextState = `DecodeAddress;

case (presentState)	

	// STATE 1:
	`DecodeAddress : begin
		if (pktValid == 1) begin
			if (dataIn == 0 & flagEm0) 
				nextState = `LoadFirstData;
			else if(dataIn == 1 & flagEm1)
				nextState = `LoadFirstData;
			else if(dataIn == 2 & flagEm2)
				nextState = `LoadFirstData;
			else
				nextState = `WaitTillEmpty;
		end
		else
			nextState = `DecodeAddress;
	end
	
	// STATE 2: Unconditional transition.
	`LoadFirstData: nextState = `LoadData;
	
	// STATE 3: 
	`LoadData : begin
		if (flagFull == 1)
			nextState = `FIFO_FullState;
		else if(!pktValid && !flagFull)
			nextState = `LoadParity;
		else 
			nextState = `LoadData;
		end
		
	// STATE 4: Unconditional transition
	`LoadParity : nextState = `CheckParity;
	
	// STATE 5: 
	`CheckParity : begin
		if(flagFull == 1)
			nextState = `FIFO_FullState;
		else
			nextState = `DecodeAddress;
	end
	
	//	STATE 6:
	`FIFO_FullState : begin
		if(!flagFull)
			nextState = `LoadAfterFull;
		else
			nextState = `FIFO_FullState;
	end
	
	// STATE 7:
	`LoadAfterFull : begin
		if (parityDone)
			nextState = `DecodeAddress;
		else if(!parityDone && !lowPktValid)
			nextState = `LoadData;
		else
			nextState = `LoadParity;
	end
	
	// STATE 8:
	`WaitTillEmpty: begin
		if (tempData == 2'b00 && flagEm0)
			nextState = `LoadFirstData;
		else if (tempData == 2'b01 && flagEm1)
			nextState = `LoadFirstData;
		else if (tempData == 2'b10 && flagEm2)
			nextState = `LoadFirstData;
		else
			nextState = `WaitTillEmpty;
	end
	endcase
end
	
// OUTPUT LOGIC
assign detectAdd = (presentState == `DecodeAddress)?1'b1:1'b0;
assign ldState = (presentState == `LoadData)?1'b1:1'b0;
assign lfdState = (presentState == `LoadFirstData)?1'b1:1'b0;
assign lafState = (presentState == `LoadAfterFull)?1'b1:1'b0;
assign rst_int_reg = (presentState == `CheckParity)?1'b1:1'b0;
assign fullState = (presentState == `FIFO_FullState)?1'b1:1'b0;
assign w_en_reg = (presentState == `LoadData || presentState == `LoadAfterFull || presentState == `LoadParity)?1'b1:1'b0;
assign busy = (presentState != `DecodeAddress || presentState != `LoadData)?1'b1:1'b0;

endmodule


