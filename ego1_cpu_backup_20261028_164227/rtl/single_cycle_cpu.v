`timescale 1ns / 1ps

// One instruction retires per enabled clock edge with asynchronous memories.
// fault is a sticky laboratory diagnostic, not a privileged ISA exception.
module single_cycle_cpu (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] instruction,
    input  wire        instruction_valid,
    input  wire [31:0] data_rdata,
    input  wire        data_fault,
    output wire [31:0] pc,
    output wire [31:0] next_pc,
    output reg         fault,
    output wire        data_req,
    output wire        data_we,
    output wire [31:0] data_addr,
    output wire [31:0] data_wdata,
    output reg         trace_valid,
    output reg  [31:0] trace_pc,
    output reg  [31:0] trace_instruction,
    output reg  [31:0] trace_next_pc,
    output reg         trace_rd_we,
    output reg  [4:0]  trace_rd,
    output reg  [31:0] trace_wdata,
    output reg         trace_mem_req,
    output reg         trace_mem_we,
    output reg  [31:0] trace_mem_addr,
    output reg  [31:0] trace_mem_wdata,
    output reg         trace_branch_taken
);
    wire legal, reg_write, use_imm, mem_read, mem_write;
    wire [4:0] raddr1, raddr2, rd;
    wire [3:0] alu_op;
    wire [1:0] branch_kind;
    wire [31:0] immediate, branch_offset, rdata1, rdata2, alu_result;
    wire [31:0] operand_b = use_imm ? immediate : rdata2;
    wire [31:0] writeback = mem_read ? data_rdata : alu_result;
    wire running = !reset && !fault;
    wire current_error = !instruction_valid || !legal || (pc[1:0] != 2'b00) || data_fault;
    wire commit = running && !current_error;
    wire rf_we = commit && reg_write && (rd != 5'd0);
    wire branch_taken = (branch_kind == 2'd1) ||
        ((branch_kind == 2'd2) && (rdata1 == rdata2)) ||
        ((branch_kind == 2'd3) && (rdata1 != rdata2));

    assign next_pc = branch_taken ? pc + branch_offset : pc + 32'd4;
    // Request is independent of data_fault, avoiding a combinational loop.
    assign data_req = running && (mem_read || mem_write);
    assign data_we = commit && mem_write;
    assign data_addr = alu_result;
    assign data_wdata = rdata2;

    program_counter u_pc (
        .clk(clk), .reset(reset), .enable(commit), .next_pc(next_pc), .pc(pc)
    );
    loongarch_decoder u_decoder (
        .instruction(instruction), .legal(legal), .raddr1(raddr1), .raddr2(raddr2),
        .rd(rd), .reg_write(reg_write), .alu_op(alu_op), .use_imm(use_imm),
        .immediate(immediate), .mem_read(mem_read), .mem_write(mem_write),
        .branch_kind(branch_kind), .branch_offset(branch_offset)
    );
    regfile32 u_regfile (
        .clk(clk), .reset(reset), .we(rf_we), .waddr(rd), .wdata(writeback),
        .raddr1(raddr1), .raddr2(raddr2), .rdata1(rdata1), .rdata2(rdata2)
    );
    alu32 u_alu (
        .a(rdata1), .b(operand_b), .alu_op(alu_op), .result(alu_result), .zero()
    );

    always @(posedge clk) begin
        if (reset) begin
            fault <= 1'b0;
            trace_valid <= 1'b0;
            trace_pc <= 32'd0;
            trace_instruction <= 32'd0;
            trace_next_pc <= 32'd0;
            trace_rd_we <= 1'b0;
            trace_rd <= 5'd0;
            trace_wdata <= 32'd0;
            trace_mem_req <= 1'b0;
            trace_mem_we <= 1'b0;
            trace_mem_addr <= 32'd0;
            trace_mem_wdata <= 32'd0;
            trace_branch_taken <= 1'b0;
        end else begin
            if (current_error)
                fault <= 1'b1;
            trace_valid <= commit;
            trace_rd_we <= rf_we;
            trace_mem_req <= commit && (mem_read || mem_write);
            trace_mem_we <= data_we;
            if (commit) begin
                trace_pc <= pc;
                trace_instruction <= instruction;
                trace_next_pc <= next_pc;
                trace_rd <= rf_we ? rd : 5'd0;
                trace_wdata <= rf_we ? writeback : 32'd0;
                trace_mem_addr <= (mem_read || mem_write) ? data_addr : 32'd0;
                trace_mem_wdata <= mem_write ? data_wdata : 32'd0;
                trace_branch_taken <= branch_taken;
            end
        end
    end
endmodule
