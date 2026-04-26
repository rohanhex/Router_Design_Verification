`timescale 1ns/1ps
module Register_TB();

// Inputs as reg type variable:
reg clk, rstn, flagFull, detectAdd, pktValid, rst_int_reg, ldState, lfdState, lafState, fullState;
reg [7:0] dataIn;

// Outputs as wire type:
wire parityDone, lowPktValid, error;
wire [7:0] dataOut;

// Instantiating the DUT:
Register_RTL	DUT(clk, rstn, dataIn, flagFull, detectAdd, pktValid, rst_int_reg, ldState, lfdState, lafState, fullState,  parityDone, lowPktValid, error, dataOut);

// Clock Generation:
parameter TimePeriod = 10;
initial	begin
clk = 1'b0;
forever
#(TimePeriod/2) clk = ~clk;
end

// Hard Reset task:
task hardReset();	begin
// The Inputs are always applied at negedge while the RTL Design samples those input at posedge; hold violations is avoided.
@(negedge clk)
	rstn =1'b0;
@(negedge clk)
	rstn = 1'b1;
end
endtask

// Initializing the Register:
task initialize();	begin
{flagFull, detectAdd, pktValid, rst_int_reg, ldState, lfdState, lafState, fullState} = 1'b0;
dataIn = 8'h00;
end
endtask

// Packet generation:
task dataPacket();	begin
reg [7:0] header;
reg [7:0] payload;
reg [7:0] parity;
reg [1:0] addFIFO;
reg [5:0] payLength;

@(negedge clk)
	payLength = 6'd8;
	addFIFO = 2'b00;
	pktValid = 1'b1;
	detectAdd = 1'b1;
	
	header = {payLength,addFIFO};
	dataIn = header;
	parity = 8'h00 ^ header;
	
@(negedge clk)
	detectAdd = 1'b0;
	lfdState = 1'b1;
	fullState = 1'b0;
	flagFull = 1'b0;
	lafState = 1'b0;
	
integer i;
for (i=0; i<payLength; i +=1)	begin
	@(negedge clk)
		lfdState = 1'b0;
		ldState = 1'b1;
		payload = ($urandom)%256;
		dataIn = payload;
		parity = parity ^ dataIn;
end

@(negedge clk) 
	pktValid = 1'b0;
	dataIn = parity;
	
@(negedge clk)
	ldState = 1'b0;
	
end
endtask

// Applying the stimulus:
initial	begin
initialize();
hardReset();

$display("data packet is being generated for Port 0");
dataPacket();
#(10 * TimePeriod);
$display("Packet transfer is done");
$finish;
end
endmodule



