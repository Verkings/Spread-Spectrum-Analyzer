module wrapper(clk,rst, addr,Wdata,write, Rdata, read, pushADC, Rdata31, Rdata30, Rdata29, Rdata28, Rdata27, Rdata26, Rdata25, Rdata24, Rdata23, Rdata22, Rdata21, Rdata20, Rdata19, Rdata18, Rdata17, Rdata16, Rdata15, Rdata14, Rdata13, Rdata12, Rdata11, Rdata10, Rdata9, Rdata8, Rdata7, Rdata6, Rdata5, Rdata4, Rdata3, Rdata2, Rdata1, Rdata0,cseen31,cseen30,cseen29,cseen28,cseen27,cseen26,cseen25,cseen24,cseen23,cseen22,cseen21,cseen20,cseen19,cseen18,cseen17,cseen16,cseen15,cseen14,cseen13,cseen12,cseen11,cseen10,cseen9,cseen8,cseen7,cseen6,cseen5,cseen4,cseen3,cseen2,cseen1,cseen0);
input clk,rst,read,write,pushADC;
input [31:0] Wdata,addr;
output [31:0] Rdata;
input [31:0]  Rdata31, Rdata30, Rdata29, Rdata28, Rdata27, Rdata26, Rdata25, Rdata24, Rdata23, Rdata22, Rdata21, Rdata20, Rdata19, Rdata18, Rdata17, Rdata16, Rdata15, Rdata14, Rdata13, Rdata12, Rdata11, Rdata10, Rdata9, Rdata8, Rdata7, Rdata6, Rdata5, Rdata4, Rdata3, Rdata2, Rdata1, Rdata0;

wire [31:0] CorrelationSeen;
input cseen31,cseen30,cseen29,cseen28,cseen27,cseen26,cseen25,cseen24,cseen23,cseen22,cseen21,cseen20,cseen19,cseen18,cseen17,cseen16,cseen15,cseen14,cseen13,cseen12,cseen11,cseen10,cseen9,cseen8,cseen7,cseen6,cseen5,cseen4,cseen3,cseen2,cseen1,cseen0; 
reg [31:0] Global_Run,Rdata_tmp,Sample_Count;


assign Rdata=Rdata_tmp;
assign CorrelationSeen[31:0]={cseen31,cseen30,cseen29,cseen28,cseen27,cseen26,cseen25,cseen24,cseen23,cseen22,cseen21,cseen20,cseen19,cseen18,cseen17,cseen16,cseen15,cseen14,cseen13,cseen12,cseen11,cseen10,cseen9,cseen8,cseen7,cseen6,cseen5,cseen4,cseen3,cseen2,cseen1,cseen0};
always @(posedge clk)
begin
if(rst)
begin
Sample_Count<=0;
Global_Run<=0;
end
else
begin
    if(write && ((addr==32'hfe00_0100)))
    Global_Run<= #1 Wdata;
    else if(write &&  (addr==32'hfe00_0104))
    Sample_Count<= #1 Wdata;
    else if(pushADC && (Global_Run!=0))
    Sample_Count<= #1 Sample_Count+1;
    
end
end



always @(*)
begin
    if(rst)
    Rdata_tmp=0;
    else 
    begin
    if(read && (addr==32'hfe00_0100))
    Rdata_tmp=Global_Run;
    else if(read && (addr==32'hfe00_0104))
    Rdata_tmp=Sample_Count;
    else if(read && (addr==32'hfe00_0108))
    Rdata_tmp=CorrelationSeen;
    
   // begin
    
		else if  ((addr[31:4]==28'hfe00_020)||(addr[31:4]==28'hfe00_040)||(addr[31:4]==28'hfe00_060))
		Rdata_tmp=Rdata0;
		else if((addr[31:4]==28'hfe00_021)||(addr[31:4]==28'hfe00_041)||(addr[31:4]==28'hfe00_061))
		Rdata_tmp=Rdata1;
		else if((addr[31:4]==28'hfe00_022)||(addr[31:4]==28'hfe00_042)||(addr[31:4]==28'hfe00_062))
		Rdata_tmp=Rdata2;
		else if((addr[31:4]==28'hfe00_023)||(addr[31:4]==28'hfe00_043)||(addr[31:4]==28'hfe00_063))
		Rdata_tmp=Rdata3;
		else if((addr[31:4]==28'hfe00_024)||(addr[31:4]==28'hfe00_044)||(addr[31:4]==28'hfe00_064))
		Rdata_tmp=Rdata4;
		else if((addr[31:4]==28'hfe00_025)||(addr[31:4]==28'hfe00_045)||(addr[31:4]==28'hfe00_065))
		Rdata_tmp=Rdata5;
		else if((addr[31:4]==28'hfe00_026)||(addr[31:4]==28'hfe00_046)||(addr[31:4]==28'hfe00_066))
		Rdata_tmp=Rdata6;
		else if((addr[31:4]==28'hfe00_027)||(addr[31:4]==28'hfe00_047)||(addr[31:4]==28'hfe00_067))
		Rdata_tmp=Rdata7;
		else if((addr[31:4]==28'hfe00_028)||(addr[31:4]==28'hfe00_048)||(addr[31:4]==28'hfe00_068))
		Rdata_tmp=Rdata8;
		else if((addr[31:4]==28'hfe00_029)||(addr[31:4]==28'hfe00_049)||(addr[31:4]==28'hfe00_069))
		Rdata_tmp=Rdata9;
		else if((addr[31:4]==28'hfe00_02a)||(addr[31:4]==28'hfe00_04a)||(addr[31:4]==28'hfe00_06a))
		Rdata_tmp=Rdata10;
		else if((addr[31:4]==28'hfe00_02b)||(addr[31:4]==28'hfe00_04b)||(addr[31:4]==28'hfe00_06b))
		Rdata_tmp=Rdata11;
		else if((addr[31:4]==28'hfe00_02c)||(addr[31:4]==28'hfe00_04c)||(addr[31:4]==28'hfe00_06c))
		Rdata_tmp=Rdata12;
		else if((addr[31:4]==28'hfe00_02d)||(addr[31:4]==28'hfe00_04d)||(addr[31:4]==28'hfe00_06d))
		Rdata_tmp=Rdata13;
		else if((addr[31:4]==28'hfe00_02e)||(addr[31:4]==28'hfe00_04e)||(addr[31:4]==28'hfe00_06e))
		Rdata_tmp=Rdata14;
		else if((addr[31:4]==28'hfe00_02f)||(addr[31:4]==28'hfe00_04f)||(addr[31:4]==28'hfe00_06f))
		Rdata_tmp=Rdata15;
		else if((addr[31:4]==28'hfe00_030)||(addr[31:4]==28'hfe00_050)||(addr[31:4]==28'hfe00_070))
		Rdata_tmp=Rdata16;
		else if((addr[31:4]==28'hfe00_031)||(addr[31:4]==28'hfe00_051)||(addr[31:4]==28'hfe00_071))
		Rdata_tmp=Rdata17;
		else if((addr[31:4]==28'hfe00_032)||(addr[31:4]==28'hfe00_052)||(addr[31:4]==28'hfe00_072))
		Rdata_tmp=Rdata18;
		else if((addr[31:4]==28'hfe00_033)||(addr[31:4]==28'hfe00_053)||(addr[31:4]==28'hfe00_073))
		Rdata_tmp=Rdata19;
		else if((addr[31:4]==28'hfe00_034)||(addr[31:4]==28'hfe00_054)||(addr[31:4]==28'hfe00_074))
		Rdata_tmp=Rdata20;
		else if((addr[31:4]==28'hfe00_035)||(addr[31:4]==28'hfe00_055)||(addr[31:4]==28'hfe00_075))
		Rdata_tmp=Rdata21;
		else if((addr[31:4]==28'hfe00_036)||(addr[31:4]==28'hfe00_056)||(addr[31:4]==28'hfe00_076))
		Rdata_tmp=Rdata22;
		else if((addr[31:4]==28'hfe00_037)||(addr[31:4]==28'hfe00_057)||(addr[31:4]==28'hfe00_077))
		Rdata_tmp=Rdata23;
		else if((addr[31:4]==28'hfe00_038)||(addr[31:4]==28'hfe00_058)||(addr[31:4]==28'hfe00_078))
		Rdata_tmp=Rdata24;
		else if((addr[31:4]==28'hfe00_039)||(addr[31:4]==28'hfe00_059)||(addr[31:4]==28'hfe00_079))
		Rdata_tmp=Rdata25;
		else if((addr[31:4]==28'hfe00_03a)||(addr[31:4]==28'hfe00_05a)||(addr[31:4]==28'hfe00_07a))
		Rdata_tmp=Rdata26;
		else if((addr[31:4]==28'hfe00_03b)||(addr[31:4]==28'hfe00_05b)||(addr[31:4]==28'hfe00_07b))
		Rdata_tmp=Rdata27;
		else if((addr[31:4]==28'hfe00_03c)||(addr[31:4]==28'hfe00_05c)||(addr[31:4]==28'hfe00_07c))
		Rdata_tmp=Rdata28;
		else if((addr[31:4]==28'hfe00_03d)||(addr[31:4]==28'hfe00_05d)||(addr[31:4]==28'hfe00_07d))
		Rdata_tmp=Rdata29;
		else if((addr[31:4]==28'hfe00_03e)||(addr[31:4]==28'hfe00_05e)||(addr[31:4]==28'hfe00_07e))
		Rdata_tmp=Rdata30;
		else if((addr[31:4]==28'hfe00_03f)||(addr[31:4]==28'hfe00_05f)||(addr[31:4]==28'hfe00_07f))
		Rdata_tmp=Rdata31;
		else
		Rdata_tmp=Rdata_tmp;

	
	end



end
endmodule