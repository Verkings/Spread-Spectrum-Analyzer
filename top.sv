`timescale 1ns/10ps
// A simple top level connector for the test bench development
//
// student --- Parth Desai
// student --- Krutarth Rami
// 

module top;

logic clk;
logic rst; 
logic [31:0] addr;
logic [31:0] Wdata;
logic write;
logic [31:0] Rdata;
logic read;
logic [15:0] ADC;
logic pushADC;


test t(clk, rst, addr, Wdata, write, Rdata, read,
	ADC, pushADC);
	
ssc s(clk,rst,addr,Wdata,write,Rdata,read,ADC,pushADC);


endmodule

