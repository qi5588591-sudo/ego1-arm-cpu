`timescale 1ns/1ps
module pipeline_fault_test #(parameter CORE=1,CASE_ID=0)(input wire clk,
    output reg done=0,output integer checks=0);
    reg reset=1;
    wire fault,trace_valid,trace_executed,trace_rd_we,trace_mem_req,trace_mem_we,trace_byte;
    wire [31:0] trace_pc,trace_instruction,trace_next_pc,trace_wdata,trace_mem_addr,trace_mem_wdata;
    wire [31:0] result_word,sum_word,status_word,fault_pc,expected_fault_pc;
    wire [31:0] cycle_count,retired_count,stall_count,load_stall_count;
    wire [31:0] flag_stall_count,flush_count,forward_count,flag_forward_count;
    wire [31:0] debug_r0,debug_r1,debug_r3;
    wire [3:0] trace_rd,trace_nzcv,nzcv;
    wire actual_store;
    integer retired=0,actual_stores=0,waited;
    pipeline_fixture #(.IMAGE(3),.CORE(CORE),.CASE_ID(CASE_ID)) dut(.*);
    always @(posedge clk)if(!reset&&actual_store)actual_stores<=actual_stores+1;
    task automatic check(input string label,input [31:0] actual,expected);
        if(actual!==expected)$fatal(1,"fault case=%0d core=%0d %s actual=%h expected=%h",CASE_ID,CORE,label,actual,expected);
        else checks++;
    endtask
    task automatic expect_trace(input [31:0] pc,inst,next_pc,executed,rd_we,rd,wdata,
                                mem_req,mem_we,byte_access,mem_addr,mem_wdata,flags);
        integer delay_count;
        delay_count=0;
        do begin
            @(posedge clk);#1;delay_count++;
            if(fault||delay_count>40)$fatal(1,"Older instruction did not retire before fault case=%0d core=%0d",CASE_ID,CORE);
        end while(!trace_valid);
        check("PC",trace_pc,pc);check("instruction",trace_instruction,inst);check("next PC",trace_next_pc,next_pc);
        check("condition",trace_executed,executed);check("reg write",trace_rd_we,rd_we);
        check("rd",trace_rd,rd);check("wdata",trace_wdata,wdata);check("mem req",trace_mem_req,mem_req);
        check("mem we",trace_mem_we,mem_we);check("byte",trace_byte,byte_access);
        check("addr",trace_mem_addr,mem_addr);check("store data",trace_mem_wdata,mem_wdata);
        check("NZCV",trace_nzcv,flags);retired++;
    endtask
    initial begin
        repeat(3)@(posedge clk);@(negedge clk);reset=0;
        case(CASE_ID)
            0:begin
            `include "fault0_expected.vh"
            end
            1:begin
            `include "fault1_expected.vh"
            end
            2:begin
            `include "fault2_expected.vh"
            end
            3:begin
            `include "fault3_expected.vh"
            end
            4:begin
            `include "fault4_expected.vh"
            end
            5:begin
            `include "fault5_expected.vh"
            end
            6:begin
            `include "fault6_expected.vh"
            end
            7:begin
            `include "fault7_expected.vh"
            end
            8:begin
            `include "fault8_expected.vh"
            end
            9:begin
            `include "fault9_expected.vh"
            end
            10:begin
            `include "fault10_expected.vh"
            end
            11:begin
            `include "fault11_expected.vh"
            end
            12:begin
            `include "fault12_expected.vh"
            end
            13:begin
            `include "fault13_expected.vh"
            end
            14:begin
            `include "fault14_expected.vh"
            end
            15:begin
            `include "fault15_expected.vh"
            end
            16:begin
            `include "fault16_expected.vh"
            end
            17:begin
            `include "fault17_expected.vh"
            end
            18:begin
            `include "fault18_expected.vh"
            end
            19:begin
            `include "fault19_expected.vh"
            end
            20:begin
            `include "fault20_expected.vh"
            end
            21:begin
            `include "fault21_expected.vh"
            end
            22:begin
            `include "fault22_expected.vh"
            end
        endcase
        waited=0;
        while(!fault)begin
            @(posedge clk);#1;waited++;
            check("no younger retirement",trace_valid,0);
            if(waited>40)$fatal(1,"Missing fault");
        end
        check("fault PC",fault_pc,expected_fault_pc);check("older R0",debug_r0,42);
        check("older R1",debug_r1,43);check("no younger R3",debug_r3,0);
        check("older NZCV",nzcv,6);check("older store",result_word,42);
        check("no younger store",status_word,0);check("exactly one physical store",actual_stores,1);
        if(CASE_ID==20||CASE_ID==21)
            check("wrong-path MDU never starts",dut.g_pipeline.cpu.mdu_start_count,0);
        if(CASE_ID==22) begin
            check("older MDU retired",dut.g_pipeline.cpu.u_regs.regs[2],126);
            check("older MDU requested once",dut.g_pipeline.cpu.mdu_start_count,1);
        end
        repeat(4)begin
            @(posedge clk);#1;
            check("sticky fault",fault,1);check("no retirement",trace_valid,0);
            check("no memory writes",actual_store,0);
        end
        @(negedge clk);reset=1;@(posedge clk);#1;
        check("reset fault",fault,0);check("reset registers",debug_r0,0);check("reset flags",nzcv,0);
        done=1;
    end
endmodule

