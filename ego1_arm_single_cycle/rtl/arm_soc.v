`timescale 1ns/1ps
module arm_soc(input wire clk,reset,output wire fault,
    output wire [31:0] result_word,sum_word,status_word,
    output wire trace_valid,trace_executed,trace_rd_we,trace_mem_req,trace_mem_we,trace_byte,
    output wire [31:0] trace_pc,trace_instruction,trace_next_pc,trace_wdata,
    output wire [31:0] trace_mem_addr,trace_mem_wdata,
    output wire [3:0] trace_rd,trace_nzcv);
    wire [31:0] pc,instruction,data_rdata,data_addr,data_wdata;
    wire instruction_valid,data_address_valid,data_req,data_we,data_byte;
    wire [3:0] nzcv;
    arm_demo_rom u_rom(.address(pc),.instruction(instruction),.valid(instruction_valid));
    arm_data_ram u_ram(.clk(clk),.reset(reset),.we(data_we),.byte_access(data_byte),
        .address(data_addr),.wdata(data_wdata),.rdata(data_rdata),.address_valid(data_address_valid),
        .result_word(result_word),.sum_word(sum_word),.status_word(status_word));
    arm_single_cycle_cpu u_cpu(.clk(clk),.reset(reset),.instruction(instruction),
        .instruction_valid(instruction_valid),.data_rdata(data_rdata),.data_address_valid(data_address_valid),
        .pc(pc),.nzcv(nzcv),.fault(fault),.data_req(data_req),.data_we(data_we),.data_byte(data_byte),
        .data_addr(data_addr),.data_wdata(data_wdata),.trace_valid(trace_valid),.trace_executed(trace_executed),
        .trace_rd_we(trace_rd_we),.trace_mem_req(trace_mem_req),.trace_mem_we(trace_mem_we),.trace_byte(trace_byte),
        .trace_pc(trace_pc),.trace_instruction(trace_instruction),.trace_next_pc(trace_next_pc),
        .trace_wdata(trace_wdata),.trace_mem_addr(trace_mem_addr),.trace_mem_wdata(trace_mem_wdata),
        .trace_rd(trace_rd),.trace_nzcv(trace_nzcv));
endmodule
