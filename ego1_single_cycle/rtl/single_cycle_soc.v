`timescale 1ns / 1ps

// Simulation/RTL-validation top. A board wrapper will be added separately.
module single_cycle_soc (
    input  wire        clk,
    input  wire        reset,
    output wire [31:0] pc,
    output wire [31:0] instruction,
    output wire [31:0] next_pc,
    output wire        fault,
    output wire [31:0] result_word,
    output wire [31:0] sum_word,
    output wire [31:0] status_word,
    output wire        trace_valid,
    output wire [31:0] trace_pc,
    output wire [31:0] trace_instruction,
    output wire [31:0] trace_next_pc,
    output wire        trace_rd_we,
    output wire [4:0]  trace_rd,
    output wire [31:0] trace_wdata,
    output wire        trace_mem_req,
    output wire        trace_mem_we,
    output wire [31:0] trace_mem_addr,
    output wire [31:0] trace_mem_wdata,
    output wire        trace_branch_taken
);
    wire instruction_valid, data_req, data_we, data_address_valid;
    wire [31:0] data_addr, data_wdata, data_rdata;
    wire data_fault = data_req && !data_address_valid;

    instruction_rom u_rom (
        .address(pc), .instruction(instruction), .valid(instruction_valid)
    );
    data_ram u_ram (
        .clk(clk), .reset(reset), .we(data_we), .address(data_addr), .wdata(data_wdata),
        .rdata(data_rdata), .address_valid(data_address_valid),
        .result_word(result_word), .sum_word(sum_word), .status_word(status_word)
    );
    single_cycle_cpu u_cpu (
        .clk(clk), .reset(reset), .instruction(instruction), .instruction_valid(instruction_valid),
        .data_rdata(data_rdata), .data_fault(data_fault), .pc(pc), .next_pc(next_pc),
        .fault(fault), .data_req(data_req), .data_we(data_we),
        .data_addr(data_addr), .data_wdata(data_wdata),
        .trace_valid(trace_valid), .trace_pc(trace_pc), .trace_instruction(trace_instruction),
        .trace_next_pc(trace_next_pc), .trace_rd_we(trace_rd_we), .trace_rd(trace_rd),
        .trace_wdata(trace_wdata), .trace_mem_req(trace_mem_req), .trace_mem_we(trace_mem_we),
        .trace_mem_addr(trace_mem_addr), .trace_mem_wdata(trace_mem_wdata),
        .trace_branch_taken(trace_branch_taken)
    );
endmodule
