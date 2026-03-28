`timescale 1ns/1ps
module Synchronous_FIFO_TB();

// Declaring all the inputs as reg type and output as wire type:
reg clk, rstn, soft_rst, w_en, r_en, lfd_state;
reg [7:0] data_in;
wire flag_full, flag_empty;
wire [7:0] data_out;

//Instantiating the DUT:
Synchronous_FIFO_RTL  DUT(clk, rstn, w_en, r_en, soft_rst, data_in, lfd_state, flag_empty, flag_full, data_out);

//Clock Generation:
parameter TimePeriod = 10;
initial begin
clk = 1'b0;
forever
# (TimePeriod)/2  clk = ~clk;
end

//Defining tasks to apply the stimulus to the FIFO:
//Task 1: Hard Reset
task hard_reset; begin
@(negedge clk)
rstn = 1'b0;
@(negedge clk)
rstn = 1'b1;
end
endtask

//Task 2: Soft Reset
task soft_reset; begin
@(negedge clk)
soft_rst = 1'b1;
@(negedge clk)
soft_rst = 1'b0;
end
endtask

//Task 3: Initialise the FIFO
task initialise; begin
w_en = 0;
r_en = 0;
lfd_state = 0;
data_in = 8'h00;
end 
endtask

//Task 4: Generating the data packet
task data_packet; begin
reg [7:0] header;
reg [7:0] payload;
reg [7:0] parity;
reg [1:0] addr;
reg [5:0] length;
integer i;
// inputs are applied to FIFO at negedge of the clock

// 1st clock edge header byte is loaded into FIFO:
@(negedge clk) begin
w_en = 1'b1;
length = 6'd16;
addr = 2'b01;
header = {length,addr};
data_in = header;
lfd_state = 1'b1;
end

// At 2nd clock edge the lfd_state is made 0
@(negedge clk)
lfd_state = 1'b0;

//3rd clock edge onwards payload is being loaded into FIFO:
for(i=0; i<14; i+=1) begin
@(negedge clk) begin
payload = $random % 256;
data_in = payload
end
end

// At 17th clock edge parity byte is loaded
@(negedge clk) begin
parity = $random % 256;
data_in = parity;
$display("At %t : flag full status = %b", $time, flag_full);
end

// At the 18th clock the writing is finished
@(negedge clk) begin
w_en = 1'b0;
data_in
end
end
endtask

// Task 5: Reading the data from FIFO:
task read; begin
integer j;
@(negedge clk)
r_en = 1'b1;

// 16 clock edges are required to read the 16 data payloads
for(j=0; j<16; j+=1) begin
@(negedge clk)
$display("At time %t: Data Output= %b", $time, data_out);
end 

//Finish Reading Data
@(negedge clk) 
r_en = 1'b0;
end
endtask

// Applying the stimulus to the FIFO:
initial begin
initialise;
# TimePeriod;
soft_reset;
hard_reset;
# TimePeriod;

// Writing the data packet
$display("Writing the data onto FIFO");
data_packet;
// Waiting time
# 5*TimePeriod;

//Reading the data
$display("Readng the data");
read;
# 5*TimePeriod;

$display("Test Complete");
$finish;
end 
endmodule





