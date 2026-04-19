`timescale 1ns/1ps
module Synchronizer_TB();

// Declaring all the input signal to DUT as reg type
reg clk, rstn, detectAdd, w_en_reg, flagFull0, flagFull1, flagFull2, flagEm0, flagEm1, flagEm2, r_en0, r_en1, r_en2;
reg [1:0] dataIn;

//Declaring all the outputs as wire type
wire [2:0] w_en;
wire validOut0, validOut1, validOut2, fifoFull, soft_rst0, soft_rst1, soft_rst2;

// Instantiating the DUT:
Synchronizer_RTL  DUT(clk, rstn, detectAdd, dataIn, w_en_reg, flagFull0, flagFull1, flagFull2, flagEm0, flagEm1, flagEm2, r_en0, r_en1, r_en2, validOut0, validOut1, validOut2, fifoFull, soft_rst0, soft_rst1, soft_rst2, w_en);

// Clock Generation:
parameter TimePeriod = 10;
initial begin
clk = 1'b0;
forever
#(TimePeriod)/2  clk = ~clk;
end

// Task to reset the Synchronizer:
task reset_sync();	begin
@(negedge clk)
rstn = 1'b0;
@(negedge clk)
rstn = 1'b1;
end
endtask

// Task to initialize the Synchronizer:
task initialize_sync();	begin
detectAdd = 1'b0;
// Flag full logic:
flagFull0 = 1'b0;
flagFull1 = 1'b0;
flagFull2 = 1'b0;
// Flag Empty Logic:
flagEm0 = 1'b1;
flagEm1 = 1'b1;
flagEm2 = 1'b1;

w_en_reg = 1'b0;
r_en0 = 1'b0;
r_en1 = 1'b0;
r_en2 = 1'b0;
end
endtask

// Task to allow address input to the Synchronizer:
task input_sync( input [1:0] in);	begin
@(negedge clk)	begin
w_en_reg = 1'b1;
detectAdd = 1'b1;
dataIn = in;
end
@(negedge clk)
detectAdd = 1'b0;
end
endtask

// Applying the stimulus
initial	begin
initialize_sync();
reset_sync();
#(TimePeriod);

// Test Case 1: Route to FIFO 0
$display("Testing FIFO 0 Routing...");
input_sync(2'b00);
flagFull0 = 1'b1;
#TimePeriod;
if (fifoFull) $display("FIFO 0 is Full");
flagFull0 =1'b0;

#TimePeriod;
// Test Case 2: Route to FIFO 1:
$display("Testing FIFO 1 Routing...");
input_sync(2'b01);
flagFull1 = 1'b1;
#TimePeriod;
if (fifoFull) $display("FIFO 1 is Full");
flagFull0 =1'b0;

// Test Case 3: Testing the soft reset for FIFO 0:
$display("Testing Soft Reset for FIFO 0...");
// We leave r_en0 = 0 and validOut0 will be 1 (because flagEm0=0)
flagEm0 = 1'b0; 
#(35 * TimePeriod); // Wait longer than 30 cycles
$display("Test Complete");
$finish;
end
endmodule


