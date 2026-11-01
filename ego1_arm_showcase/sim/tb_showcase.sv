`timescale 1ns/1ps
module tb_showcase;
 reg clk=0;always #5 clk=~clk;reg[4:0] btn=0;
 wire[7:0] info,digit,s0,s1;wire hb,pass,fault,complete;
 ego1_arm_showcase_top #(.DEBOUNCE(4),.SCAN_TICKS(6)) dut(.clk(clk),.btn(btn),.led_info(info),.digit(digit),.segment0(s0),.segment1(s1),.led_heartbeat(hb),.led_pass(pass),.led_fault(fault),.led_complete(complete));
 integer checks=0,i,p;reg[7:0] digits_seen=0;
 `include "showcase_lanes.vh"
 task check(input bit ok,input string msg);begin if(!ok)$fatal(1,"%s",msg);checks++;end endtask
 task press(input integer n);begin @(negedge dut.cpu_clk);btn[n]=1;repeat(12)@(negedge dut.cpu_clk);btn[n]=0;repeat(12)@(negedge dut.cpu_clk);end endtask
 task finished;begin wait(complete);repeat(4)@(negedge dut.cpu_clk);check(!fault,"Program fault");end endtask
 initial begin
  finished();
  check(&dut.seen,"All 24 records seen");
  // Eight digit enables must scan, exactly one at a time, both banks equal.
  for(i=0;i<120;i=i+1)begin
   @(negedge dut.cpu_clk);
   check((digit&(digit-1))==0,"More than one digit enabled");
   check(s0==s1,"Segment banks differ");
   if(digit!=0)digits_seen=digits_seen|digit;
  end
  check(digits_seen==8'hff,"All eight digit enables must scan");
  for(i=0;i<24;i=i+1)begin
   check(dut.selected==i,"Selection order");
   check(pass&&!fault,"Actual record vs reference");
   check(dut.page_limit==exp_pages(i),"Page count");
   for(p=0;p<exp_pages(i);p=p+1)begin
    check(dut.page==p,"Page index");
   check(info[4:0]==i+1,"Case LEDs");
   check(info[7:5]==(3'b001<<dut.page),"Page LEDs");
    if(dut.display_lanes!=exp_lane(i,p))
     $display("MISMATCH i=%0d p=%0d got=%016x exp=%016x kind=%0d",
              i,p,dut.display_lanes,exp_lane(i,p),dut.cur_kind);
    check(dut.display_lanes==exp_lane(i,p),"Display page");
    press(2);
   end
   check(dut.page==0,"Page wrap");
   press(1);
  end
  check(dut.selected==0,"Next wraps");
  press(3);check(dut.selected==23,"Previous wraps");
  press(1);check(dut.selected==0,"Back to first");
  // A long press must act exactly once.
  @(negedge dut.cpu_clk);btn[1]=1;repeat(80)@(negedge dut.cpu_clk);
  check(dut.selected==1,"Held button repeats");
  btn[1]=0;repeat(12)@(negedge dut.cpu_clk);
  // A pulse shorter than the debounce window is ignored.
  btn[1]=1;@(negedge dut.cpu_clk);btn[1]=0;repeat(12)@(negedge dut.cpu_clk);
  check(dut.selected==1,"Bounce changed selection");
  press(4);finished();check(&dut.seen,"Rerun must recapture all records");
  press(0);finished();check(dut.selected==0&&dut.page==0,"S0 reset UI");
  $display("SHOWCASE TESTS PASSED: %0d",checks);$finish;
 end
 initial begin #15000000;$fatal(1,"Showcase timeout");end
endmodule
