# Router_Design_Verification
Router is an OSI layer 3 routing device that forwards data packet b/w computer networks. It drives an incoming packet to an output channel based on the address field in the data packet.
It is commonly called as The Traffic Director of Networks.

The OSI (Open System Interconnect) model is a standard way how the sustems in a network communicate with each other. The Router operates at layer 3 ie Network Layer.

Working of a Router:
1. Rx. an incoming packet
2. Examine the packet header
3. Consult the routing table
4. Drive the data packet to putput channel.

A 1x3 Router implies there is one input WAN port from the modem and 3 output LAN ports for 3 different wired channel. The router stores the incoming packet inside a FIFO as per address in the packet. To confirm the correctness of the packet recieved by router, an error detection mechanism is introduced in the packet design.
Router 1x3 Features:
1. Packet Routing: The packet is driven from the input port & is routed to any one output port, based on address present in the data packet.
2. Parity Check: An error detection technique that tests the i tegrity of digital data being tx.
3. Reset: It resets the router. All FIFOs are emptied & signals are set to low so that na packets are transmitted.

Data Packet:
The data packet consists of 3 parts--
1. Header: 8 bits in length. Lower 2 bits store the address of output & Higher 6 bits store the length of payload. A total of 64 payloads can be sent.
2. Payload: 8 bits in length. The actual data containing information.
3. Parity: 8 bits in length.

Block Level Architecture:
The router contains 4 modules-
1. Synchronous FIFOs ( 3 in number )
2. Synchronizer
3. Finite State Machine
4. Registers

All the inputs to router are synced to negative edge of the clock while all the outputs are sampled at positive edge of the clock. This creates a half cycle offset between input signals & output signal and prevent the hold time violations.
The FIFO size is 16x9.
The purpose of synchronizer is to provide sync between the FIFO modules and the FSM of the router. It provides faithful communication b/w the input & output ports.
The FSM is the controller circuit for the router. This module generates all the control signals whenever a packet is recieved by router. The control signals are used by other modules to transmit the packet.

This repository contains the design files of this 1x3 router. The RTL design is done using verilog hdl and the design is verified using testbench. All the designs are made on Quartus Prime & Quartus Altera.
