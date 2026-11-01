`timescale 1ns / 1ps

module cpu_top(
    input clk,
    input rst,
    output [7:0] pc_debug,
    output [15:0] ins_debug,
    output [3:0] opcode_debug,
    output [7:0] operand_debug,
    output [15:0] acc_debug,
    output [15:0] mem_data_debug,
    output [15:0] alu_result_debug,
    output acc_we_debug,
    output mem_we_debug,
    output jump_debug,
    output branch_debug,
    output halted_debug,
    output [7:0] next_pc_debug,
    output [15:0] mem8_debug,
    output [15:0] mem4_debug,
    output [15:0] mem6_debug,
    output [15:0] mem18_debug,
    output [15:0] mem20_debug
);

    wire [7:0] pc_out;
    wire [7:0] next_pc;
    wire [15:0] instr;
    wire [3:0] opcode;
    wire [7:0] operand;

    wire [15:0] acc_out;
    wire [15:0] mem_data;
    wire [15:0] alu_result;

    wire acc_we;
    wire mem_we;
    wire jump;
    wire branch;
    wire halt;
    wire [3:0] alu_op;

    wire acc_negative;

    assign opcode = instr[15:12];
    assign operand = instr[7:0];
    assign acc_negative = acc_out[15];

    assign next_pc = (jump || branch) ? operand : pc_out + 8'd1;

    pc u_pc (
        .clk(clk),
        .rst(rst),
        .halt(halt),
        .next_pc(next_pc),
        .pc_out(pc_out)
    );

    imem u_imem (
        .addr(pc_out),
        .instr(instr)
    );

    control u_control (
        .opcode(opcode),
        .acc_negative(acc_negative),
        .acc_we(acc_we),
        .mem_we(mem_we),
        .jump(jump),
        .branch(branch),
        .halt(halt),
        .alu_op(alu_op)
    );

    dmem u_dmem (
        .clk(clk),
        .rst(rst),
        .mem_we(mem_we),
        .addr(operand),
        .write_data(acc_out),
        .read_data(mem_data),
        .mem8_debug(mem8_debug),
        .mem4_debug(mem4_debug),
        .mem6_debug(mem6_debug),
        .mem18_debug(mem18_debug),
        .mem20_debug(mem20_debug)
    );

    alu u_alu (
        .acc_in(acc_out),
        .mem_data(mem_data),
        .alu_op(alu_op),
        .alu_result(alu_result)
    );

    acc u_acc (
        .clk(clk),
        .rst(rst),
        .acc_we(acc_we),
        .acc_in(alu_result),
        .acc_out(acc_out)
    );

    assign pc_debug = pc_out;
    assign ins_debug = instr;
    assign opcode_debug = opcode;
    assign operand_debug = operand;
    assign acc_debug = acc_out;
    assign mem_data_debug = mem_data;
    assign alu_result_debug = alu_result;
    assign acc_we_debug = acc_we;
    assign mem_we_debug = mem_we;
    assign jump_debug = jump;
    assign branch_debug = branch;
    assign halted_debug = halt;
    assign next_pc_debug = next_pc;

endmodule