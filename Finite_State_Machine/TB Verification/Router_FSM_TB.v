`timescale 1ns/1ps
module FSM_TB();

// Declaring all inputs as reg type:
reg clk, rstn, soft_rst0, soft_rst1, soft_rst2, flagEm0, flagEm1, flagEm2, flagFull, pktValid, lowPktValid, parityDone;
reg [1:0] dataIn;
// Declaring output signals as wire type:
wire busy, detectAdd, w_en_reg, ldState, lafState, lfdState, fullState, rst_int_reg;

// Instantiating the DUT:
FSM_RTL DUT(clk, rstn, soft_rst0, soft_rst1, soft_rst2, flagEm0, flagEm1, flagEm2, flagFull, pktValid, lowPktValid, parityDone,dataIn, busy, detectAdd, w_en_reg, ldState, lafState, lfdState, fullState, rst_int_reg );

// Generating the clock
parameter TimePeriod = 10;
initial	begin
clk = 1'b0;
forever
#(TimePeriod/2) clk = ~clk;
end

// Hard Reset:
task hardReset();	begin
@(negedge clk)
	rstn = 1'b0;
@(negedge clk)
	rstn = 1'b1;
end
endtask

// Initialising the FSM
task initialize();	begin
dataIn = 2'b00;
pktValid = 1'b0;
flagFull = 1'b0;
parityDone = 1'b0;
lowPktValid = 1'b0;
flagEm0 = 1'b1;
flagEm1 = 1'b1;
flagEm2 = 1'b1;
end
endtask

// Soft Reset
task softReset();	begin
@(negedge clk)
	soft_rst0 = 1'b1;
	soft_rst1 = 1'b1;
	soft_rst2 = 1'b1;
	
@(negedge clk)	
	soft_rst0 = 1'b0;
	soft_rst1 = 1'b0;
	soft_rst2 = 1'b0;
end
endtask

// Applying stimulus
initial begin
initialize();
hardReset();
#(TimePeriod);

// Test Case: Sending Packet to FIFO 0:
$display("Sending Packet ot FIFO 0");
@(negedge clk)
	pktValid = 1'b1;
	dataIn = 2'b00; // Address for FIFO 0
// FSM should move: Decode -> LoadFirstData -> LoadData
#(3* TimePeriod);

// Simulate Packet Ending
pktValid = 1'b0;
// FSM should move: LoadData -> LoadParity -> CheckParity -> Decode
#(5 * TimePeriod);
$display("Test Complete");
$finish;
end

// 
