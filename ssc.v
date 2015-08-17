`timescale 1ns/10ps
`include "case.v"
`include "ssc0.v"
`include "ssc1.v"
`include "ssc2.v"
`include "ssc3.v"
`include "ssc4.v"
`include "ssc5.v"
`include "ssc6.v"
`include "ssc7.v"
`include "ssc8.v"
`include "ssc9.v"
`include "ssc10.v"
`include "ssc11.v"
`include "ssc12.v"
`include "ssc13.v"
`include "ssc14.v"
`include "ssc15.v"
`include "ssc16.v"
`include "ssc17.v"
`include "ssc18.v"
`include "ssc19.v"
`include "ssc20.v"
`include "ssc21.v"
`include "ssc22.v"
`include "ssc23.v"
`include "ssc24.v"
`include "ssc25.v"
`include "ssc26.v"
`include "ssc27.v"
`include "ssc28.v"
`include "ssc29.v"
`include "ssc30.v"
`include "ssc31.v"
module ssc(clk,rst, addr,Wdata,write, Rdata, read,ADC, pushADC); 
input clk,rst,read,write,pushADC;
input [31:0] Wdata,addr;
output [31:0] Rdata;
input [15:0]  ADC;
wire [31:0]  Rdata31, Rdata30, Rdata29, Rdata28, Rdata27, Rdata26, Rdata25, Rdata24, Rdata23, Rdata22, Rdata21, Rdata20, Rdata19, Rdata18, Rdata17, Rdata16, Rdata15, Rdata14, Rdata13, Rdata12, Rdata11, Rdata10, Rdata9, Rdata8, Rdata7, Rdata6, Rdata5, Rdata4, Rdata3, Rdata2, Rdata1, Rdata0;
wire cseen31,cseen30,cseen29,cseen28,cseen27,cseen26,cseen25,cseen24,cseen23,cseen22,cseen21,cseen20,cseen19,cseen18,cseen17,cseen16,cseen15,cseen14,cseen13,cseen12,cseen11,cseen10,cseen9,cseen8,cseen7,cseen6,cseen5,cseen4,cseen3,cseen2,cseen1,cseen0;

wrapper w (clk,rst, addr,Wdata,write, Rdata, read, pushADC, Rdata31, Rdata30, Rdata29, Rdata28, Rdata27, Rdata26, Rdata25, Rdata24, Rdata23, Rdata22, Rdata21, Rdata20, Rdata19, Rdata18, Rdata17, Rdata16, Rdata15, Rdata14, Rdata13, Rdata12, Rdata11, Rdata10, Rdata9, Rdata8, Rdata7, Rdata6, Rdata5, Rdata4, Rdata3, Rdata2, Rdata1, Rdata0,cseen31,cseen30,cseen29,cseen28,cseen27,cseen26,cseen25,cseen24,cseen23,cseen22,cseen21,cseen20,cseen19,cseen18,cseen17,cseen16,cseen15,cseen14,cseen13,cseen12,cseen11,cseen10,cseen9,cseen8,cseen7,cseen6,cseen5,cseen4,cseen3,cseen2,cseen1,cseen0);

ssc0 s0 (clk,rst, addr,Wdata,write, Rdata0, read,ADC, pushADC, cseen0);
ssc1 s1 (clk,rst, addr,Wdata,write, Rdata1, read,ADC, pushADC, cseen1);
ssc2 s2 (clk,rst, addr,Wdata,write, Rdata2, read,ADC, pushADC, cseen2);
ssc3 s3 (clk,rst, addr,Wdata,write, Rdata3, read,ADC, pushADC, cseen3);
ssc4 s4 (clk,rst, addr,Wdata,write, Rdata4, read,ADC, pushADC, cseen4);
ssc5 s5 (clk,rst, addr,Wdata,write, Rdata5, read,ADC, pushADC, cseen5);
ssc6 s6 (clk,rst, addr,Wdata,write, Rdata6, read,ADC, pushADC, cseen6);
ssc7 s7 (clk,rst, addr,Wdata,write, Rdata7, read,ADC, pushADC, cseen7);
ssc8 s8 (clk,rst, addr,Wdata,write, Rdata8, read,ADC, pushADC, cseen8);
ssc9 s9 (clk,rst, addr,Wdata,write, Rdata9, read,ADC, pushADC, cseen9);
ssc10 s10 (clk,rst, addr,Wdata,write, Rdata10, read,ADC, pushADC, cseen10);
ssc11 s11 (clk,rst, addr,Wdata,write, Rdata11, read,ADC, pushADC, cseen11);
ssc12 s12 (clk,rst, addr,Wdata,write, Rdata12, read,ADC, pushADC, cseen12);
ssc13 s13 (clk,rst, addr,Wdata,write, Rdata13, read,ADC, pushADC, cseen13);
ssc14 s14 (clk,rst, addr,Wdata,write, Rdata14, read,ADC, pushADC, cseen14);
ssc15 s15 (clk,rst, addr,Wdata,write, Rdata15, read,ADC, pushADC, cseen15);
ssc16 s16 (clk,rst, addr,Wdata,write, Rdata16, read,ADC, pushADC, cseen16);
ssc17 s17 (clk,rst, addr,Wdata,write, Rdata17, read,ADC, pushADC, cseen17);
ssc18 s18 (clk,rst, addr,Wdata,write, Rdata18, read,ADC, pushADC, cseen18);
ssc19 s19 (clk,rst, addr,Wdata,write, Rdata19, read,ADC, pushADC, cseen19);
ssc20 s20 (clk,rst, addr,Wdata,write, Rdata20, read,ADC, pushADC, cseen20);
ssc21 s21 (clk,rst, addr,Wdata,write, Rdata21, read,ADC, pushADC, cseen21);
ssc22 s22 (clk,rst, addr,Wdata,write, Rdata22, read,ADC, pushADC, cseen22);
ssc23 s23 (clk,rst, addr,Wdata,write, Rdata23, read,ADC, pushADC, cseen23);
ssc24 s24 (clk,rst, addr,Wdata,write, Rdata24, read,ADC, pushADC, cseen24);
ssc25 s25 (clk,rst, addr,Wdata,write, Rdata25, read,ADC, pushADC, cseen25);
ssc26 s26 (clk,rst, addr,Wdata,write, Rdata26, read,ADC, pushADC, cseen26);
ssc27 s27 (clk,rst, addr,Wdata,write, Rdata27, read,ADC, pushADC, cseen27);
ssc28 s28 (clk,rst, addr,Wdata,write, Rdata28, read,ADC, pushADC, cseen28);
ssc29 s29 (clk,rst, addr,Wdata,write, Rdata29, read,ADC, pushADC, cseen29);
ssc30 s30 (clk,rst, addr,Wdata,write, Rdata30, read,ADC, pushADC, cseen30);
ssc31 s31 (clk,rst, addr,Wdata,write, Rdata31, read,ADC, pushADC, cseen31);





















endmodule