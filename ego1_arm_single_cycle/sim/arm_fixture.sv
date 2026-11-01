`timescale 1ns/1ps
module arm_fixture #(parameter STRESS=0)(input wire clk,reset,
    output wire fault,trace_valid,trace_executed,trace_rd_we,trace_mem_req,trace_mem_we,trace_byte,
    output wire [31:0] trace_pc,trace_instruction,trace_next_pc,trace_wdata,trace_mem_addr,trace_mem_wdata,
    output wire [3:0] trace_rd,trace_nzcv,
    output wire [31:0] result_word,sum_word,status_word);
    generate if(!STRESS) begin: g_demo
        arm_soc u_soc(.*);
    end else begin: g_stress
        wire [31:0] pc,instruction,data_rdata,data_addr,data_wdata;
        wire instruction_valid,data_address_valid,data_req,data_we,data_byte;
        wire [3:0] nzcv;
        arm_stress_rom u_rom(.address(pc),.instruction(instruction),.valid(instruction_valid));
        arm_data_ram u_ram(.clk(clk),.reset(reset),.we(data_we),.byte_access(data_byte),
            .address(data_addr),.wdata(data_wdata),.rdata(data_rdata),.address_valid(data_address_valid),
            .result_word(result_word),.sum_word(sum_word),.status_word(status_word));
        arm_single_cycle_cpu u_cpu(.*);
    end endgenerate
endmodule

module arm_program_test #(parameter STRESS=0)(input wire clk,output reg done=0,output integer checks=0);
    reg reset=1;
    wire fault,trace_valid,trace_executed,trace_rd_we,trace_mem_req,trace_mem_we,trace_byte;
    wire [31:0] trace_pc,trace_instruction,trace_next_pc,trace_wdata,trace_mem_addr,trace_mem_wdata;
    wire [31:0] result_word,sum_word,status_word;
    wire [3:0] trace_rd,trace_nzcv;
    integer retired=0;
    arm_fixture #(.STRESS(STRESS)) dut(.*);
    task automatic check(input string label,input [31:0] actual,expected);
        if(actual!==expected) $fatal(1,"ARM image=%0d retire=%0d %s actual=%08h expected=%08h",STRESS,retired,label,actual,expected);
        else checks++;
    endtask
    task automatic expect_trace(input [31:0] pc,inst,next_pc,executed,rd_we,rd,wdata,
                                mem_req,mem_we,byte_access,mem_addr,mem_wdata,flags);
        @(posedge clk);#1;
        check("fault",fault,0);check("valid",trace_valid,1);
        check("PC",trace_pc,pc);check("instruction",trace_instruction,inst);
        check("next PC",trace_next_pc,next_pc);check("condition",trace_executed,executed);
        check("reg write",trace_rd_we,rd_we);check("rd",trace_rd,rd);check("wdata",trace_wdata,wdata);
        check("mem req",trace_mem_req,mem_req);check("mem write",trace_mem_we,mem_we);
        check("byte",trace_byte,byte_access);check("address",trace_mem_addr,mem_addr);
        check("store data",trace_mem_wdata,mem_wdata);check("NZCV",trace_nzcv,flags);
        retired++;
    endtask
    initial begin
        repeat(3) @(posedge clk);@(negedge clk);reset=0;
        if(STRESS) begin
            `include "stress_expected.vh"
        end else begin
            `include "demo_expected.vh"
            check("7+5",result_word,12);check("sum 1..5",sum_word,15);check("status",status_word,1);
        end
        $display("ARM PROGRAM PASSED: image=%0d retired=%0d checks=%0d",STRESS,retired,checks);
        done=1;
    end
endmodule
