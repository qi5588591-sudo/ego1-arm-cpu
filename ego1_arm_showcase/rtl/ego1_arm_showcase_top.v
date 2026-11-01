`timescale 1ns/1ps
// Two- or three-page demo: case number plus one value per page.
// Page content is fixed by the generated catalog; the last page is always the
// value the CPU really retired, so D15 means "actual == reference model".
module ego1_arm_showcase_top #(parameter integer DEBOUNCE=10000,SCAN_TICKS=250)(
 input wire clk,input wire[4:0] btn,
 output wire[7:0] led_info,output wire led_heartbeat,led_pass,led_fault,led_complete,
 output wire[7:0] digit,segment0,segment1);
 reg[25:0] hb=0;assign led_heartbeat=hb[25];
 always @(posedge clk) hb<=hb+1;
 reg[5:0] div=0;reg div_clk=0;wire cpu_clk;
 always @(posedge clk) if(div==49)begin div<=0;div_clk<=~div_clk;end else div<=div+1;
 BUFG u_cpu_clock(.I(div_clk),.O(cpu_clk));
 wire[4:0] held,pulse;
 genvar b;generate for(b=0;b<5;b=b+1)begin:buttons
  board_button #(.DEBOUNCE(DEBOUNCE)) u_button(.clk(cpu_clk),.pin(btn[b]),.pressed(held[b]),.pulse(pulse[b]));
 end endgenerate
 reg[3:0] reset_left=15;wire cpu_reset=(reset_left!=0)||held[0];
 reg[4:0] selected=0;reg[1:0] page=0;
 reg[23:0] seen=0;
 reg[31:0] rec_pc[0:23],rec_ins[0:23],rec_next[0:23],rec_wdata[0:23],rec_mem[0:23];
 reg[3:0] rec_flags[0:23];
 wire fault,tv,te,rdwe,mreq,mwe,byte_access;
 wire[31:0] tpc,tins,tnext,tvalue,taddr,tmdata;
 wire[3:0] trd,tflags;
 wire[31:0] result_word,sum_word,status_word;
 arm_pipeline_soc u_soc(.clk(cpu_clk),.reset(cpu_reset),.fault(fault),
  .result_word(result_word),.sum_word(sum_word),.status_word(status_word),
  .trace_valid(tv),.trace_executed(te),.trace_rd_we(rdwe),.trace_mem_req(mreq),
  .trace_mem_we(mwe),.trace_byte(byte_access),.trace_pc(tpc),.trace_instruction(tins),
  .trace_next_pc(tnext),.trace_wdata(tvalue),.trace_mem_addr(taddr),.trace_mem_wdata(tmdata),
  .trace_rd(trd),.trace_nzcv(tflags));
 wire found;wire[4:0] ri;
 wire npages;
 wire[2:0] p0_kind,p1_kind,p2_kind;
 wire[63:0] p0_lanes,p1_lanes,p2_lanes,num_lanes;
 wire[31:0] ei,ev,em,en;wire[3:0] ef;
 showcase_catalog catalog(.selected(selected),.trace_pc(tpc),.found(found),.record_index(ri),
  .npages(npages),.p0_kind(p0_kind),.p1_kind(p1_kind),.p2_kind(p2_kind),
  .p0_lanes(p0_lanes),.p1_lanes(p1_lanes),.p2_lanes(p2_lanes),.num_lanes(num_lanes),
  .expected_ins(ei),.expected_value(ev),.expected_mem(em),.expected_next(en),.expected_flags(ef));
 wire[1:0] page_limit=npages?2'd3:2'd2;
 wire[2:0] cur_kind=(page==2'd0) ? p0_kind : (page==2'd1) ? p1_kind : p2_kind;
 wire[63:0] cur_static=(page==2'd0) ? p0_lanes : (page==2'd1) ? p1_lanes : p2_lanes;
 wire[31:0] cur_value=(cur_kind==3'd1) ? rec_wdata[selected] :
                      (cur_kind==3'd5) ? rec_wdata[selected] :
                      (cur_kind==3'd2) ? rec_mem[selected] :
                      (cur_kind==3'd6) ? rec_pc[selected] :
                      (cur_kind==3'd3) ? rec_next[selected] :
                      {28'd0,rec_flags[selected]};
 wire[47:0] fmt_lanes;
 showcase_format u_format(.value(cur_value),.kind(cur_kind),.lanes(fmt_lanes));
 wire[63:0] display_lanes=(cur_kind==3'd0) ? cur_static : (num_lanes | {16'h0000,fmt_lanes});
 reg complete=0,program_failed=0;
 wire sample_ok=seen[selected]&&rec_ins[selected]==ei&&rec_wdata[selected]==ev&&
                rec_mem[selected]==em&&rec_next[selected]==en&&rec_flags[selected]==ef;
 assign led_pass=sample_ok&&!fault&&!program_failed;
 assign led_fault=fault||program_failed||(seen[selected]&&!sample_ok);
 assign led_complete=complete&&(&seen);
 // D1-D5: case number in binary. D6/D7/D8: one-hot for page 1/2/3.
 assign led_info={page==2'd2,page==2'd1,page==2'd0,selected+5'd1};
 integer i;
 always @(posedge cpu_clk) begin
  if(reset_left!=0) reset_left<=reset_left-1;
  if(held[0])begin reset_left<=4;selected<=0;page<=0;end
  else if(pulse[4])reset_left<=4;
  else begin
   if(pulse[1])selected<=(selected==23)?0:selected+1;
   else if(pulse[3])selected<=(selected==0)?23:selected-1;
   if(pulse[2])page<=(page==page_limit-1)?0:page+1;
  end
  if(cpu_reset||pulse[4])begin
   seen<=0;complete<=0;program_failed<=0;
   for(i=0;i<24;i=i+1)begin rec_pc[i]<=0;rec_ins[i]<=0;rec_next[i]<=0;
    rec_wdata[i]<=0;rec_mem[i]<=0;rec_flags[i]<=0;end
  end else if(tv)begin
   if(te&&found&&!seen[ri])begin
    seen[ri]<=1;rec_pc[ri]<=tpc;rec_ins[ri]<=tins;rec_next[ri]<=tnext;
    rec_wdata[ri]<=tvalue;rec_mem[ri]<=tmdata;rec_flags[ri]<=tflags;
   end
   if(mwe&&taddr==32'h1008)begin
    complete<=tmdata==1&&result_word==12&&sum_word==15&&status_word==1;
    program_failed<=!(tmdata==1&&result_word==12&&sum_word==15&&status_word==1);
   end
  end
 end
 showcase_display #(.SCAN_TICKS(SCAN_TICKS)) display(.clk(cpu_clk),.lanes(display_lanes),
  .digit(digit),.segment0(segment0),.segment1(segment1));
endmodule

