`timescale 1ns / 1ps

module single_cpu(
    input clk,
    input rst,
    output [7:0] pc_debug,
    output [15:0] ins_debug,
    output [6:0] opcode_debug,
    output [2:0] r1_addr_debug,
    output [2:0] r2_addr_debug,
    output [2:0] r3_addr_debug,
    output wr_en_debug,
    output [15:0] reg_data1_debug,
    output [15:0] reg_data2_debug,
    output [15:0] alu_result_debug,
    output [15:0] r1_debug,
    output [15:0] r2_debug,
    output [15:0] r3_debug,
    output [15:0] r4_debug,
    output [15:0] r5_debug,
    output [15:0] r6_debug,
    output [15:0] r7_debug
);

    wire [7:0] pc_out;
    wire [15:0] instr;

    wire [6:0] opcode;
    wire [2:0] r1_addr;
    wire [2:0] r2_addr;
    wire [2:0] r3_addr;

    wire wr_en;
    wire [2:0] alu_op;

    wire [15:0] reg_data1;
    wire [15:0] reg_data2;
    wire [15:0] alu_result;
    wire zero;

    pc u_pc (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out)
    );

    imem u_imem (
        .addr(pc_out),
        .instr(instr)
    );

    assign opcode = instr[15:9];
    assign r1_addr = instr[8:6];
    assign r2_addr = instr[5:3];
    assign r3_addr = instr[2:0];

    control u_control (
        .opcode(opcode),
        .wr_en(wr_en),
        .alu_op(alu_op)
    );

    regfile u_regfile (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .read_addr1(r1_addr),
        .read_addr2(r2_addr),
        .write_addr(r3_addr),
        .write_data(alu_result),
        .read_data1(reg_data1),
        .read_data2(reg_data2),
        .r1_debug(r1_debug),
        .r2_debug(r2_debug),
        .r3_debug(r3_debug),
        .r4_debug(r4_debug),
        .r5_debug(r5_debug),
        .r6_debug(r6_debug),
        .r7_debug(r7_debug)
    );

    alu u_alu (
        .a(reg_data1),
        .b(reg_data2),
        .alu_op(alu_op),
        .result(alu_result),
        .zero(zero)
    );

    assign pc_debug = pc_out;
    assign ins_debug = instr;
    assign opcode_debug = opcode;
    assign r1_addr_debug = r1_addr;
    assign r2_addr_debug = r2_addr;
    assign r3_addr_debug = r3_addr;
    assign wr_en_debug = wr_en;
    assign reg_data1_debug = reg_data1;
    assign reg_data2_debug = reg_data2;
    assign alu_result_debug = alu_result;

endmodule