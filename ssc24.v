`timescale 1ns/10ps

module ssc24(clk,rst, addr,Wdata,write, Rdata24, read,ADC, pushADC, cseen24); 



	
	input clk,rst,read,write,pushADC;
	input [31:0] Wdata,addr;
	output [31:0] Rdata24;
	input [15:0]  ADC;
	output cseen24;
	
	reg [31:0] Global_Run,Sample_Count,Freq00_DDS_Add,Freq00_DDS_control,Freq00_DDS_Phase,Freq00_DDS_phase_adj;
	reg [31:0] Sample_Count_d,Sample_Count_d1;
	reg [31:0]Chip00_DDS_Freq,Chip00_DDS_Phase,Chip00_DDS_Phase_adj,PRN00,Chip00_DDS_Phase_tmp;
	reg[31:0] CorrelationSeen,Correlation00Cnt,Correlation00Low,Correlation00High,Correlation0Status;
	reg pushADC_tmp,pushADC_tmp1,pushADC_tmp2;
	reg [1:0] quad;
	reg[31:0]CorrelationSeen_d;
	reg [31:0] Rdata_tmp,tmp_data,tmp_ADC;
	reg [31:0] chip,dds;
	reg [15:0] tmp_addr,addr_d,Sample,sval;
	reg[3:0]hob,x;
	reg[13:0]poly,val,prn00_d,prn00_d1;  //PRN registers
	reg signed [31:0]ADC_ext,ADC_ext_d,sval_d,sval1,sval_d1;
	reg [12:0]sin_addr;
	reg signed [63:0] product,correlation_d,correlation,product_d;
	wire[15:0]sv;
	wire[12:0]phase_position;
	
	sine s1(.v(phase_position),.sv(sv));
	assign Rdata24=Rdata_tmp;
	assign phase_position=sin_addr;
	assign cseen24=CorrelationSeen[24];
	always @(posedge clk or posedge rst)
	begin
	  if(rst)
	    begin
	    Global_Run<=0;
	    Sample_Count<=0;
	    Freq00_DDS_Add<=0;
	    Freq00_DDS_control<=0;
	    Freq00_DDS_Phase<=0;
	    Freq00_DDS_phase_adj<=0;
	    
	    Sample<=0;
	    Sample_Count<=0;
	    
	    Chip00_DDS_Freq<=0;
	    Chip00_DDS_Phase<=0;
	    Chip00_DDS_Phase_adj<=0;
	    Chip00_DDS_Phase_tmp<=0;
	    PRN00<=0;
	    prn00_d<=
	    prn00_d1<=
	    pushADC_tmp<=0;
	    pushADC_tmp1<=0;
	    pushADC_tmp2<=0;
	    Correlation00Cnt<=0;
	    Correlation00Low<=0;
	    Correlation00High<=0;
	    Correlation0Status<=0;
	    Sample<=0;
	    correlation_d<=0;
	    CorrelationSeen_d<=0;
	    addr_d<=0;
	    sval_d<=0;
	    Sample_Count_d<=0;
	    Sample_Count_d1<=0;
	    ADC_ext_d<=0;
	    product_d<=0;
	    end
	  else
	    begin
	      Sample<=#1 tmp_ADC;
	      pushADC_tmp<=#1 pushADC;
	      pushADC_tmp1<=#1 pushADC_tmp;
	      pushADC_tmp2<=#1 pushADC_tmp1;
	      addr_d<=#1 tmp_addr;
	      prn00_d<=#1PRN00[13:0];
	      prn00_d1<=#1prn00_d;
	      sval_d1<=sval_d;
	      Sample_Count_d<=#1Sample_Count;
	      Sample_Count_d1<=#1Sample_Count_d;
	      if(pushADC_tmp)
	      sval_d<= sval1;
	      
	      ADC_ext_d<=#1ADC_ext;
	      if(pushADC_tmp1)
	      product_d<=#1product;
	      if(pushADC_tmp2)
	      correlation_d<=#1correlation;
	      if((prn00_d==1)&& (prn00_d1!=1)&&(pushADC_tmp2))
	      begin
	      {Correlation00High,Correlation00Low}<=correlation_d+product_d;
	      correlation_d<=#1 0;
	      Correlation00Cnt<=#1Sample_Count_d1-1;
	      CorrelationSeen_d<=#1 1;
	      
	      Correlation0Status<=#1 32'b1;
	      end
	      else
	      begin

	      if(read && (addr_d==16'h108))
	      CorrelationSeen_d<=#1 0;
	      if(read && (tmp_addr==16'h78c)&&(addr_d!=16'h78c))
	      Correlation0Status<=#1 32'b0;
	      Correlation00Cnt<=#1Correlation00Cnt;
	      end
	      if(pushADC && (Global_Run)&& Freq00_DDS_control[0])
	      begin
	//      $display("DDS24 Functioning");
	      Sample<=#1 tmp_ADC;
	      Freq00_DDS_Phase<=#1 dds;
	      Freq00_DDS_phase_adj<=#1 32'h0;

	      Chip00_DDS_Phase<=#1 chip;
	      Chip00_DDS_Phase_adj<=#1 32'h0;	      
	      Chip00_DDS_Phase_tmp<=#1 Chip00_DDS_Phase;
	      
	      Sample_Count<=#1 Sample_Count+1;
	      
	      sval<=sv;
	      quad<=#1Freq00_DDS_Phase[31:30];
	      
	  
	      end
	      else
	      begin
	      sval<=#1 0;
	      Sample<=#1Sample;
	      Sample_Count<=#1Sample_Count;
	      quad<=#1 0;
	      end
	     
	      
	      if((Chip00_DDS_Phase[31]==1'b1)&&(Chip00_DDS_Phase_tmp[31]==1'b0)&&(pushADC_tmp))
		  begin
		      
		      PRN00[13:0]<=#1 val;
		  end   
		  else
		      PRN00[13:0]<=#1 PRN00[13:0];
	      if(write)   
	      begin
		  case(tmp_addr)
		  16'h0100:Global_Run<=#1 tmp_data;
		  16'h0104:Sample_Count<=#1 tmp_data;
		  16'h0380:Freq00_DDS_Add<=#1 tmp_data;
		  16'h0384:Freq00_DDS_Phase<=#1 tmp_data;
		  16'h0388:Freq00_DDS_phase_adj<=#1 tmp_data;
		  16'h038c:begin Freq00_DDS_control[0]<=#1 tmp_data[0]; Freq00_DDS_control[31:1]<=#1 Freq00_DDS_control[31:1]; end
		  16'h0580:Chip00_DDS_Freq<=#1 tmp_data;
		  16'h0584:Chip00_DDS_Phase<=#1 tmp_data;
		  16'h0588:Chip00_DDS_Phase_adj<=#1 tmp_data;
		  16'h058c:begin PRN00<=#1 tmp_data; end
		  16'h0780:Correlation00Cnt<=#1 tmp_data;
		  16'h0784:Correlation00Low<=#1 tmp_data;
		  16'h0788:Correlation00High<=#1 tmp_data;
		  16'h078c:Correlation0Status<=#1 tmp_data;
		  endcase
	      end
	     
	   
	   
	    end
	
	  end
	
	
    always @(*)
    begin
	  tmp_addr=addr[15:0];
	      
	  dds=Freq00_DDS_Phase+Freq00_DDS_Add+Freq00_DDS_phase_adj;
	  chip=Chip00_DDS_Phase+Chip00_DDS_Freq+Chip00_DDS_Phase_adj;
	  tmp_ADC=ADC;
	  ADC_ext[31:16]={16{Sample[15]}};
	  ADC_ext[15:0]=Sample;
	  product=(ADC_ext_d*sval_d);
	  
	  correlation=correlation_d+product_d;
	// $display(" sval %h",sval);
	  
	  
	  if(write)
	  begin
	  tmp_data=Wdata;
	 
	  sin_addr=0;
	  Rdata_tmp=0;
	  end
	  else if(read)
	      begin
		  sin_addr=0;
		  
		  tmp_data=0;
		  case(tmp_addr)
		//  16'h0100:Rdata_tmp=Global_Run;
		//  16'h0104:Rdata_tmp=Sample_Count;
		//  16'h0108:begin Rdata_tmp[0]=CorrelationSeen[0];end
		  16'h0380:Rdata_tmp=Freq00_DDS_Add;
		  16'h0384:Rdata_tmp=Freq00_DDS_Phase;
		  16'h0388:Rdata_tmp=Freq00_DDS_phase_adj;
		  16'h038c:Rdata_tmp=Freq00_DDS_control;
		  16'h0580:Rdata_tmp=Chip00_DDS_Freq;
		  16'h0584:Rdata_tmp=Chip00_DDS_Phase;
		  16'h0588:Rdata_tmp=Chip00_DDS_Phase_adj;
		  16'h058c:Rdata_tmp=PRN00;
		  16'h0780:Rdata_tmp=Correlation00Cnt;
		  16'h0784:Rdata_tmp=Correlation00Low;
		  16'h0788:Rdata_tmp=Correlation00High;
		  16'h078c:begin Rdata_tmp=Correlation0Status;end 
		  default Rdata_tmp=0;
		  endcase
	      end
	  else if((pushADC) && (Global_Run))
	  begin
	      tmp_data=Wdata;
	      Rdata_tmp=0;
	      
	    case(Freq00_DDS_Phase[31:30])
	      2'b00:begin sin_addr=Freq00_DDS_Phase[29:17]; end//sval[31:16]={16{sv[15]}}; sval[15:0]=sv[15:0];end
	      2'b01:begin sin_addr=~(Freq00_DDS_Phase[29:17]); end //sval[31:16]={16{sv[15]}}; sval[15:0]=sv[15:0];end
	      2'b10:begin sin_addr=Freq00_DDS_Phase[29:17];end//sval[15:0]=(~sv)+16'b1;sval[31:16]={16{sval[15]}};end
	      2'b11:begin sin_addr=~(Freq00_DDS_Phase[29:17]);end //sval[15:0]=(~sv)+16'b1;sval[31:16]={16{sval[15]}};end
	    
	  endcase

// 		  
		  
		  
	  end
	  else
	  begin
	      tmp_data=0;
	      Rdata_tmp=0;
	      sin_addr=0;
	      
	  end
	  if(pushADC_tmp)
	  begin
	  case(quad)
	  2'b10:begin sval1[15:0]=(~sval)+16'b1;sval1[31:16]={16{sval1[15]}};end
	  2'b11:begin sval1[15:0]=(~sval)+16'b1;sval1[31:16]={16{sval1[15]}};end
	  default:begin sval1[31:16]={16{sval[15]}}; sval1[15:0]=sval[15:0];end
	  endcase
	  if(PRN00[hob])
	  sval1=(~sval1)+1;
	  else
	  sval1=sval1;
	  end
	  else
	  sval1=0;

	  if((CorrelationSeen_d==1)&&(prn00_d[13:0]==1))
	  begin
	  CorrelationSeen[24]=1;
	  end
	  else
	  begin
	      if((read && (addr_d==16'h108))||(rst==1'b1))
	      CorrelationSeen[24]=0;
	      else 
	      CorrelationSeen[24]=Correlation0Status[0];
	  end
	  
end
   always @ (Chip00_DDS_Phase[31])
	begin
		  if((Chip00_DDS_Phase[31]==1)&&(Global_Run))
		  begin
	//	  $display("PRN24 Functioning");
		    hob=PRN00[31:28];
		    poly=PRN00[27:14];
		    val=PRN00[13:0];
		    x=val[hob];
		    val[hob]=1'b0;
		    val=val<<1;
		    if(x)
		    val=val^poly;
		  end 
		  else
		  begin
		    val=PRN00[13:0];
		    hob=PRN00[31:28];
		    poly=PRN00[27:14];
		  end
	end




endmodule