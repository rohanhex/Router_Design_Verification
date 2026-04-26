// RTL Design for Register:
module Register_RTL(clk, rstn, dataIn, flagFull, detectAdd, pktValid, rst_int_reg, ldState, lfdState, lafState, fullState,  parityDone, lowPktValid, error, dataOut);

input clk, rstn, flagFull, detectAdd, pktValid, rst_int_reg, ldState, lfdState, lafState, fullState;
input [7:0] dataIn;

output reg parityDone, lowPktValid, error;
output reg [7:0] dataOut;

// The register need to store the packet data: header, payload & parity as well as generate & store an internal parity data to detect any error:
reg [7:0] headerByte;
reg [7:0] payloadByte;
reg [7:0] pktParityByte;
reg [7:0] internalParityByte;

// Parity Done Logic: 
always@(posedge clk)	begin
if (!rstn)
	parityDone <= 1'b0;
else if (ldState && !pktValid && !flagFull)
	parityDone <= 1'b1;
else if (lafState && lowPktValid)
	parityDone <= 1'b1;
else if (detectAdd)
	parityDone <= 1'b0;
end

// Low packet valid Logic:
always@(posedge clk)	begin
if (!rstn)
	lowPktValid <= 1'b0;
else if (ldState && !pktValid)
	lowPktValid <= 1'b1;
else if (rst_int_reg)
	lowPktValid <= 1'b0;
end

// Internal Parity Logic:
always@(posedge clk)	begin
if (!rstn)
	internalParityByte <= 8'h00;
else begin
	if (detectAdd)
		internalParityByte <= 8'h00;
	else if (lfdState)
		internalParityByte <= internalParityByte ^ headerByte;
	else if (ldState && pktValid && !fullState)
		internalParityByte <= internalParityByte ^ dataIn;
	end
end

// Packet parity logic:
always@(posedge clk)	begin
if (!rstn) 
pktParityByte <= 8'h00;
else	begin
	if (detectAdd)
		pktParityByte <= 8'h00;
	else if (ldState && !pktValid && !flagFull)
		pktParityByte <= dataIn;
	else if (lafState && lowPktValid && !parityDone)
		pktParityByte <= dataIn;
	end
end

// Error Check logic:
always@(posedge clk)	begin
if(!rstn)
	error <= 1'b0;
else if (!parityDone)
	error <= 1'b0;
else if (internalParityByte != pktParityByte)
	error <= 1'b1;
else
	error <= 1'b0;
end

// Output Logic:
always@(posedge clk)	begin
if (!rstn)	begin
	headerByte <= 8'h00;
	payloadByte <= 8'h00;
	dataOut <= 8'h00;
	end
else	begin
	if (detectAdd && pktValid && dataIn[1:0] != 2'b11)
		headerByte <= dataIn;   // The header byte is store first
	else if (lfdState)
		dataOut <= headerByte;
	else if (ldState && !flagFull)
		dataOut <= dataIn; // The payload is routed to the output
	else if (ldState && flagFull)
		payloadByte <= dataIn; // If FIFO gets full, remaining payloads get stored in the internal rgister.
	else if (lafState)
		dataOut <= payloadByte;  // The sotred payload is then routed to output.
	end
end

// 
endmodule

