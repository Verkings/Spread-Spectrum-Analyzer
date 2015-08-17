// A very simple test bench for the correlator
// It starts simple, and works it's way up to harder things
// Generated on Mon Dec  8 22:21:05 2014/n// Generated for students
//    Parth Desai
//    Krutarth Rami

//
`timescale 1ns/10ps

module test(output logic clk, output logic rst, 
	output logic [31:0] addr, output logic [31:0] Wdata,
	output logic write, input logic [31:0] Rdata, output logic read,
	output logic [15:0] ADC, output logic pushADC);

const logic debug_enabled=0;
logic global_enable=0;
logic [31:0] adc_count=0;
logic [31:0] global_correlations=0;

logic [63:0] zero_correlation;
integer sine_value;
logic [31:0] zero_ddsphase;
logic [13:0] zero_polyvalue;

class correlator;
  logic [31:0] rcontents[0:3]; 	// DDS registers
  logic [31:0] old_rcontents[0:3];
  logic [31:0] unit;		// which correlator unit are we ?
  logic [15:0] ADCval;		// The adc value for calculations
  logic [31:0] old_polyregs[0:3], polyregs[0:3];	// the polynominal registers
  logic signed [31:0] corregs[0:3],old_corregs[0:3]; 
  logic signed [63:0] correlation;  
  struct packed {
    logic [3:0] hob;
    logic [13:0] poly;
    logic [13:0] val;
  } pitem; 

  task reset;
    integer ix;
    begin
      for(ix=0; ix < 4; ix++)begin
        rcontents[ix]=0;
        polyregs[ix]=0;
        corregs[ix]=0;
      end
      correlation=0;
      zero_correlation=0;
      zero_ddsphase=0;    
    end
  endtask

  task writeDDS(input [3:0] who, input [31:0] what);
    begin
      rcontents[who]=what;
      rcontents[3]=rcontents[3]&1;
      writereg(32'hfe000200+who*4+unit*16,what);
    end
  endtask
    
  task writePoly(input [3:0] who, input [31:0] what);
    begin
      polyregs[who]=what;
      writereg(32'hfe000400+who*4+unit*16,what);
      pitem=polyregs[3];
      zero_polyvalue=pitem.val;
    end
  endtask
  
  task writeCorr(input [3:0] who, input [31:0] what);
    begin
      corregs[who]=what;
      writereg(32'hfe000600+who*4+unit*16,what);
      case(who)
        1: correlation[31:0]=what;
        2: correlation[63:32]=what;
        3: corregs[3]=corregs[3]&1;
      endcase
      corregs[3]=corregs[3]&1;
      if(unit==0) zero_correlation=correlation;
    end
  endtask

  task checkDDS(input [3:0] who);
    begin
      checkreg(32'hfe000200+who*4+unit*16,rcontents[who]);
    end
  endtask

  task checkPoly(input [3:0] who);
    begin
      checkreg(32'hfe000400+who*4+unit*16,polyregs[who]);
    end
  endtask
  
  task checkCorr(input [3:0] who);
    begin
      checkreg(32'hfe000600+who*4+unit*16,corregs[who]);
      if(who == 3) begin
        corregs[3]=0;
        global_correlations[unit]=0;
      end
    end
  endtask
  
  task checkCblob;
    begin
      checkCorr(0);
      checkCorr(1);
      checkCorr(2);
      checkCorr(3);
    end
  endtask

  task stepDDS;
    begin
      if(rcontents[3]==1 && global_enable==1) begin
        rcontents[1]=rcontents[1]+rcontents[0]+rcontents[2];
        if(rcontents[2] != 0) rcontents[2]=0;
        if(unit==0) zero_ddsphase=rcontents[1];
      end
    end
  endtask
  
  task stepPoly;
    begin
      if(rcontents[3]==1 && global_enable==1) begin
        polyregs[1]=polyregs[1]+polyregs[0]+polyregs[2];
        polyregs[2]=0;
      end
    end
  endtask
  
  task corrADC;
    logic signed [31:0] cwk,swk;
    logic signed [63:0] rwk;
    begin
      cwk = {{16{ADCval[15]}},ADCval};
      swk = sinf(old_rcontents[1][31:30],old_rcontents[1][29:17]);
      pitem=old_polyregs[3];
      if(pitem.val[pitem.hob]) swk=-swk;
      if(unit==0) begin
        sine_value=swk;
      end
      rwk = cwk*swk;
      correlation = correlation + rwk;
      if(unit==0) zero_correlation=correlation;
    end
  endtask

  task procADC(input logic [15:0] val);
    logic oldhob;
    begin
      ADCval=val;
      old_polyregs=polyregs;
      old_corregs=corregs;
      old_rcontents=rcontents;
      oldhob = old_polyregs[1][31];
      corrADC;
      stepDDS;
      stepPoly;
      if(rcontents[3]==1 && global_enable==1 && oldhob==0 && polyregs[1][31]==1) begin
        pitem = polyregs[3];
        oldhob = pitem.val[pitem.hob];
        pitem.val[pitem.hob]=0;
        pitem.val = pitem.val << 1;
        if(oldhob) pitem.val = pitem.val ^ pitem.poly;
        polyregs[3]=pitem;
        zero_polyvalue=pitem.val;
        if(pitem.val == 1) begin
          corregs[0]=adc_count;
          corregs[1]=correlation[31:0];
          corregs[2]=correlation[63:32];
          corregs[3]=1;
          global_correlations[unit]=1;
          correlation=0;
        end
      end
    end
  endtask

  function new(integer un);
    integer ix;
    begin
      unit=un;
      for(ix=0; ix < 4; ix++) begin
        rcontents[ix]=0;
        polyregs[ix]=0;
      end
    end
  endfunction
endclass
//
//-------------------------------------
//
correlator corr[0:31];

initial begin
  for(integer ix=0; ix < 32; ix++) begin
    corr[ix]=new(ix);
  end
  zero_correlation=0;
end

task debug(input string s);
begin
  if(debug_enabled) $display("%s",s);
end
endtask

task reset;
  integer ix;
  begin
    for(ix=0; ix < 32; ix++) corr[ix].reset;
    global_enable=0;
    adc_count=0;
    global_correlations=0;
  end
endtask

default clocking bus @(posedge(clk));
default input #0ns output #1ns;
  output #0 rst;
  output addr,write,read,ADC,pushADC;
  output #1.5 Wdata;
  input Rdata;
endclocking

property p_double_write;
  disable iff (write!=1) write ##1 write;
endproperty
property p_rw;
  disable iff (write== 1'bx) !(write==1'b1 && read===1'b1);
endproperty

`include "sinf.v"
	
initial begin
	clk=0;
	forever #2.5 clk=~clk;
end

initial b1:
begin
	integer ix;
	bus.addr<=0;
	bus.Wdata<=32'h55aa;
	bus.write<=0;
	bus.pushADC<= 0;
	bus.ADC<=16'h33;
	bus.read<=0;
	bus.rst<=1;
	#0;
	if(debug_enabled) begin
	  $dumpfile("tssc.vcd");
	  $dumpvars(1,top);
	end
	for(ix=0; ix < 32; ix++) begin
          if(1) begin
            $display("Starting basic testing of unit %2d\n",ix);
          end
	  bus.rst<=1;
	  #0;
	##10;
	reset();
	bus.rst<=0;
	##5;
	writereg(32'hfe000200,32'h01234567);
	writereg(32'hfe000204,32'hffff1111);
	writereg(32'hfe000208,32'h01010101);
	writereg(32'hfe00020c,32'h020c020c);
	##2;
	  testdds_regs(ix);
	  testpoly_regs(ix);
	  testcorr_regs(ix);
	  debug("Passed run\n");
	  ##100;
	end
	$info("Ending the run");
	$finish;
end

trw:	assert property(p_rw) else $fatal("\n\n\nRead and write both on\n\n\n");


task writereg(input logic [31:0] addr, input logic [31:0] data);
begin
	bus.addr <= addr;
	bus.Wdata <= data;
	bus.write <=1;
	##1;
	case(addr)
	  32'hfe000100: global_enable=data[0];
	  32'hfe000104: adc_count=0;
	endcase
	bus.write <= 0;
	//bus.Wdata <= $random;
end
endtask

task writeGlobal(input [3:0] who, input logic[31:0] what);
  begin
    writereg(32'hfe000100+who*4,what);
    case(who)
      0: global_enable=what[0];
      1: adc_count=what;
    endcase
  end
endtask

task checkGlobal(input [3:0] who);
  begin
    case(who)
      0: checkreg(32'hfe000100,{31'b0,global_enable});
      1: checkreg(32'hfe000104,adc_count);
      2: checkreg(32'hfe000108,global_correlations);
      default: $fatal("you checked a non existant global Morris");
    endcase
  end
endtask

task checkreg(input logic [31:0] addr, input logic[31:0] expected);

begin
  bus.addr <= addr;
  bus.read <= 1;
  ##1;
  assert (bus.Rdata === expected) else begin
    $display("\n\n\n\n Error, on register %h read\nExpected %h got %h\n\n\n",addr,expected,bus.Rdata);
    #10;
    $fatal("Register read error\n");
  end
  bus.read <= 0;
end
endtask

task sendADC(input logic [15:0] val);
integer ix;
begin
  bus.ADC<= val;
  bus.pushADC<= 1;
  ##1;
  bus.pushADC<= 0;
  if(!debug_enabled) bus.ADC<=$random;
  for(ix=0; ix < 32; ix++) corr[ix].procADC(val);
  adc_count = adc_count+1;
end
endtask

task testdds_regs(input integer unit);
  integer regoffset,ix;
  logic [31:0] rcontents[0:3];
  logic [31:0] rwv;
  correlator cr;
begin
  cr=corr[unit];
  debug("Starting write dds registers");
  writereg(32'hfe000100,0);
  cr.writeDDS(0,0);
  cr.writeDDS(1,0);
  cr.writeDDS(2,0);
  cr.writeDDS(3,0);
  debug("Starting read dds registers");
  cr.checkDDS(0);
  cr.checkDDS(1);
  cr.checkDDS(2);
  cr.checkDDS(3);
  checkGlobal(0);
  checkGlobal(1);
  debug("Checking register 0xfe0020c only has 1 bit");
  cr.writeDDS(3,32'hfffffffe);
  cr.checkDDS(3);
  for(ix=0; ix < 4; ix++) rcontents[ix]=0;
  debug("Starting random reads and writes");
  repeat(300) begin
    regoffset = $random&32'h0fffffff;
    regoffset = (regoffset % 3); // don't do offset 0xc
    if((($random&32'h0fffffff)%4)>2) begin
      rwv = $random;
      cr.writeDDS(regoffset,rwv);
      while(($random%32)>20) ##1;
    end else begin
      cr.checkDDS(regoffset);
      while(($random%32)>20) ##1;
    end
  end
  if(debug_enabled) $display("Checking basic function of dds %0d mechanism",unit);
  writeGlobal(0,1);
  writeGlobal(1,3);
  checkGlobal(0);
  checkGlobal(1);
  cr.writeDDS(0,32'h10101001);
  cr.writeDDS(1,32'h0);
  cr.writeDDS(2,0);
  cr.checkDDS(0);
  cr.checkDDS(1);
  cr.checkDDS(2);
  cr.writeDDS(3,1);
  debug("  DDS increment and phase adjust tests");
  repeat(500) begin
    sendADC(16'h4321);
    ##3;
    cr.checkDDS(0);
    cr.checkDDS(2);
    cr.checkDDS(1);
    cr.checkDDS(3);
    checkGlobal(0);
    checkGlobal(1);
    if((($random&32'h0fffffff)%257)>200) begin
      cr.writeDDS(2,$random&32'h00ffffff);
      cr.checkDDS(2);
    end
  end
  
end
endtask

function [31:0] polyPack(input logic [3:0] hob,input logic[13:0] poly, input [13:0] val);
  begin
    polyPack = {hob,poly,val};
  end
endfunction


task testpoly_regs(input logic[3:0] unit);
  correlator cr;
  integer ix;
  logic [3:0] rnum;
  begin
    cr = corr[unit];
    debug("Poly register check");
    debug("  Checking zero after reset");
    for(ix=0; ix < 4; ix++) cr.checkPoly(ix);
    debug("  Checking random poly register reads/writes");
    repeat(500) begin
      rnum= ($random&32'h0fffffff)%4;
      if( (($random&32'h0fffffff)%2)>0) begin
        cr.writePoly(rnum,$random);
      end else begin
        cr.checkPoly(rnum);
      end
    end
    // enable the freq dds
    cr.writeDDS(0,32'h7fffff00);
    cr.writeDDS(1,32'h0);
    cr.writeDDS(2,32'h0);
    cr.writeDDS(3,1);
    //
    cr.writePoly(0,32'h1000000);
    cr.writePoly(1,32'h0101010);
    cr.writePoly(2,0);
    cr.writePoly(3,0);	// no polynominal action yet...
    repeat(800) begin
      sendADC(16'h1234);
      ##4;
      cr.checkDDS(0);
      cr.checkDDS(1);
      cr.checkDDS(2);
      cr.checkPoly(0);
      cr.checkPoly(1);
      cr.checkPoly(2);
      cr.checkPoly(3);
      checkGlobal(1);     
    end
    debug("Starting a simple poly check");
    cr.writePoly(0,32'h41000000);
    cr.writePoly(3,polyPack(0,1,1));
    repeat(800) begin
      sendADC(16'h1234);
      ##5;
      cr.checkDDS(0);
      cr.checkDDS(1);
      cr.checkDDS(2);
      cr.checkPoly(0);
      cr.checkPoly(1);
      cr.checkPoly(2);
      cr.checkPoly(3);
      checkGlobal(1);          
    end
    debug(" Poly with HOB=3");
    cr.writePoly(3,polyPack(3,3,1));
    repeat(2000) begin
      sendADC(16'h1234);
      ##5;
      cr.checkDDS(0);
      cr.checkDDS(1);
      cr.checkDDS(2);
      cr.checkPoly(0);
      cr.checkPoly(1);
      cr.checkPoly(2);
      cr.checkPoly(3);          
    end
    debug(" Poly with HOB=7");
    cr.writePoly(3,polyPack(7,14'he,1));
    repeat(2000) begin
      sendADC(16'h1234);
      ##5;
      cr.checkDDS(0);
      cr.checkDDS(1);
      cr.checkDDS(2);
      cr.checkPoly(0);
      cr.checkPoly(1);
      cr.checkPoly(2);
      cr.checkPoly(3);
      checkGlobal(1);          
    end
    debug(" Poly with HOB=11");
    cr.writePoly(3,polyPack(11,14'h5,1));
    repeat(12000) begin
      sendADC(16'h1234);
      ##5;
      cr.checkDDS(0);
      cr.checkDDS(1);
      cr.checkDDS(2);
      cr.checkPoly(0);
      cr.checkPoly(1);
      cr.checkPoly(2);
      cr.checkPoly(3);
      checkGlobal(1);          
    end  end
endtask

task testcorr_regs(logic [3:0] unit);
  integer ix,sval,rnoise;
  correlator cr;
  begin
    cr = corr[unit];
    debug("checking the correlator registers");
    rst = 1;
    ##10;
    #1;
    rst=0;
    reset; // clear out the models
    debug("  Check that reset works");
    for(ix=0; ix < 4; ix++) begin
      cr.checkDDS(ix);
      cr.checkPoly(ix);
      cr.checkCorr(ix);
    end
    checkGlobal(0);
    checkGlobal(1);
    checkGlobal(2);
    debug(" test a simple correlation");
    writeGlobal(0,1);
    cr.writeDDS(0,32'h7fefff04);
    cr.writeDDS(1,32'h0);
    cr.writeDDS(2,32'h0);
    cr.writeDDS(3,1);
    //
    cr.writePoly(3,polyPack(3,3,1));
    cr.writePoly(0,32'h412486ef);
    cr.writeDDS(0,32'h4001000);
    ix=0;
    repeat(9000) begin
      sval = sinf(cr.rcontents[1][31:30],cr.rcontents[1][29:17]);
      if(cr.pitem.val[cr.pitem.hob]==1) sval=-sval;
      sendADC(sval);
      ix++;
      if( (ix%23)==0 ) begin
        ##1;
        cr.checkDDS(0);
        cr.checkDDS(1);
        cr.checkDDS(2);
        cr.checkDDS(3);
        cr.checkPoly(0);
        cr.checkPoly(1);
        cr.checkPoly(2);
        cr.checkPoly(3);
      end
      checkGlobal(0);
      checkGlobal(1);
      cr.checkDDS(1);
      checkGlobal(2);
      cr.checkCorr(0);
      cr.checkCorr(1);
      cr.checkCorr(2);
      cr.checkCorr(3);
    end    
    debug(" test a bigger correlation ");
    writeGlobal(0,1);
    cr.writeDDS(0,32'h0fefff05);
    cr.writeDDS(1,32'h0);
    cr.writeDDS(2,32'h0);
    cr.writeDDS(3,1);
    //
    for(ix=0; ix < 32; ix=ix+1) begin
      if(ix!=unit) begin
        corr[ix].writePoly(3,polyPack(11,14'h5,ix*5));
        corr[ix].writePoly(0,32'h1f100000+ix*1234);
        corr[ix].writePoly(1,ix*9175);
        corr[ix].writeDDS(0,32'h1e200000+ix*4321);
        corr[ix].writeDDS(1,21567*ix);
        corr[ix].writeDDS(2,0);
        corr[ix].writeDDS(3,$random&1);
      end
    end
    cr.writePoly(3,polyPack(3,3,1));
    cr.writePoly(0,32'h002486e5);
    cr.writePoly(1,0);
    ix=9;
    repeat(90000) begin
      sval = sinf(cr.rcontents[1][31:30],cr.rcontents[1][29:17]);
      if(cr.pitem.val[cr.pitem.hob]==1) sval=-sval;
      sendADC(sval);
      ##($random&32'h3);
      ix++;
      if( (ix%137)==0 ) begin
        ##4;
        cr.checkDDS(0);
        cr.checkDDS(1);
        cr.checkDDS(2);
        cr.checkDDS(3);
        cr.checkPoly(0);
        cr.checkPoly(1);
        cr.checkPoly(2);
        cr.checkPoly(3);
        cr.checkCorr(0);
        cr.checkCorr(1);
        cr.checkCorr(2);
        cr.checkCorr(3);

        corr[$random&32'h1f].checkPoly($random&32'h3);
        corr[$random&32'h1f].checkDDS($random&32'h3);
        checkGlobal(0);
        checkGlobal(1);
        checkGlobal(2);
      end
    end    
    
    debug(" test a bigger correlation poly out of phase");
    writeGlobal(0,1);
    cr.writeDDS(0,32'h0fefff01);
    cr.writeDDS(1,32'h0);
    cr.writeDDS(2,32'h0);
    cr.writeDDS(3,1);
    //
    cr.writePoly(3,polyPack(3,3,1));
    cr.writePoly(0,32'h002486e5);
    ix=0;
    repeat(90000) begin
      sval = sinf(cr.rcontents[1][31:30],cr.rcontents[1][29:17]);
      if(cr.pitem.val[cr.pitem.hob]==0) sval=-sval;
      sendADC(sval);
      ##2;
      ix++;
      if( (ix%237)==0 ) begin
        ##3;
        cr.checkDDS(0);
        cr.checkDDS(1);
        cr.checkDDS(2);
        cr.checkDDS(3);
        cr.checkPoly(0);
        cr.checkPoly(1);
        cr.checkPoly(2);
        cr.checkPoly(3);
        cr.checkCorr(0);
        cr.checkCorr(1);
        cr.checkCorr(2);
        cr.checkCorr(3);
        checkGlobal(0);
        checkGlobal(1);
        checkGlobal(2);
      end
    end    
    debug(" test a bigger correlation poly 90 degrees out of phase");
    writeGlobal(0,1);
    cr.writeDDS(0,32'h1fefff02);
    cr.writeDDS(1,32'h0);
    cr.writeDDS(2,32'h0);
    cr.writeDDS(3,1);
    //
    cr.writePoly(3,polyPack(3,3,1));
    cr.writePoly(0,32'h042486e5);
    ix=0;
    repeat(90000) begin
      sval = sinf(cr.rcontents[1][31:30]+1,cr.rcontents[1][29:17]);
      if(cr.pitem.val[cr.pitem.hob]==1) sval=-sval;
      sendADC(sval);
      if(($random & 1)>0) ##1;

      ix++;
      if( (ix%237)==0 ) begin
        ##3;
        cr.checkDDS(0);
        cr.checkDDS(1);
        cr.checkDDS(2);
        cr.checkDDS(3);
        cr.checkPoly(0);
        cr.checkPoly(1);
        cr.checkPoly(2);
        cr.checkPoly(3);
        cr.checkCorr(0);
        cr.checkCorr(1);
        cr.checkCorr(2);
        cr.checkCorr(3);
        checkGlobal(0);
        checkGlobal(1);
        checkGlobal(2);
      end
    end    
    
    debug(" test a noisy correlation");
    writeGlobal(0,1);
    cr.writeDDS(0,32'h1fefff03);
    cr.writeDDS(1,32'h0);
    cr.writeDDS(2,32'h0);
    cr.writeDDS(3,1);
    //
    cr.writePoly(3,polyPack(3,3,1));
    cr.writePoly(0,32'h042486e5);
    ix=0;
    repeat(90000) begin
      sval = sinf(cr.rcontents[1][31:30],cr.rcontents[1][29:17]);
      if(cr.pitem.val[cr.pitem.hob]==1) sval=-sval;
      sval=sval/4;
      rnoise=$random;
      rnoise=rnoise%16556;
      sval=sval + rnoise;
      sendADC(sval);


      ix++;
      if( (ix%237)==0 ) begin
        ##3;
        cr.checkDDS(0);
        cr.checkDDS(1);
        cr.checkDDS(2);
        cr.checkDDS(3);
        cr.checkPoly(0);
        cr.checkPoly(1);
        cr.checkPoly(2);
        cr.checkPoly(3);
        cr.checkCorr(0);
        cr.checkCorr(1);
        cr.checkCorr(2);
        cr.checkCorr(3);
        checkGlobal(0);
        checkGlobal(1);
        checkGlobal(2);
      end
    end    
    
  end
endtask

endmodule

