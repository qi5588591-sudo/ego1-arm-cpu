`timescale 1ns / 1ps

module cpu_top(
    input clk,
    input rst,
    output [7:0] pc_debug,
    output [15:0] ins_debug,
    output [3:0] opcode_debug,
    output [2:0] r1_addr_debug,
    output [2:0] r2_addr_debug,
    output [7:0] imm_debug,
    output [1:0] state_debug,
    output ir_we_debug,
    output ab_we_debug,
    output reg_we_debug,
    output mem_we_debug,
    output pc_we_debug,
    output pc_src_debug,
    output [15:0] reg_data1_debug,
    output [15:0] reg_data2_debug,
    output [15:0] a_reg_debug,
    output [15:0] b_reg_debug,
    output [15:0] alu_result_debug,
    output [15:0] r1_debug,
    output [15:0] r2_debug,
    output [15:0] r3_debug,
    output [15:0] r4_debug,
    output [15:0] r5_debug,
    output [15:0] r6_debug,
    output [15:0] r7_debug,
    output [15:0] mem20_debug,
    output [15:0] mem21_debug,
    output [15:0] mem22_debug
);

    wire [7:0] pc_out;
    wire [7:0] pc_next;
    wire [15:0] instr_from_mem;
    wire [15:0] instr;

    wire [3:0] opcode;
    wire [2:0] r1_addr;
    wire [2:0] r2_addr;
    wire [7:0] imm;

    wire ir_we;
    wire ab_we;
    wire reg_we;
    wire mem_we;
    wire pc_we;
    wire pc_src;
    wire [1:0] alu_op;
    wire [1:0] state;

    wire [15:0] reg_data1;
    wire [15:0] reg_data2;
    wire [15:0] a_reg;
    wire [15:0] b_reg;
    wire [15:0] alu_result;
    wire zero;
    wire [15:0] mem_read_data;

    pc u_pc (
        .clk(clk),
        .rst(rst),
        .pc_we(pc_we),
        .pc_in(pc_next),
        .pc_out(pc_out)
    );

    imem u_imem (
        .addr(pc_out),
        .instr(instr_from_mem)
    );

    ir u_ir (
        .clk(clk),
        .rst(rst),
        .ir_we(ir_we),
        .instr_in(instr_from_mem),
        .instr_out(instr)
    );

    assign opcode = instr[15:12];
    assign r1_addr = instr[11:9];
    assign r2_addr = instr[8:6];
    assign imm = instr[7:0];

    control u_control (
        .clk(clk),
        .rst(rst),
        .opcode(opcode),
        .ir_we(ir_we),
        .ab_we(ab_we),
        .reg_we(reg_we),
        .mem_we(mem_we),
        .pc_we(pc_we),
        .pc_src(pc_src),
        .alu_op(alu_op),
        .state_debug(state)
    );

    regfile u_regfile (
        .clk(clk),
        .rst(rst),
        .reg_we(reg_we),
        .read_addr1(r1_addr),
        .read_addr2(r2_addr),
        .write_addr(r1_addr),
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

    ab_reg u_ab_reg (
        .clk(clk),
        .rst(rst),
        .ab_we(ab_we),
        .a_in(reg_data1),
        .b_in(reg_data2),
        .a_out(a_reg),
        .b_out(b_reg)
    );

    alu u_alu (
        .a(a_reg),
        .b(b_reg),
        .alu_op(alu_op),
        .result(alu_result),
        .zero(zero)
    );

    dmem u_dmem (
        .clk(clk),
        .rst(rst),
        .mem_we(mem_we),
        .addr(imm),
        .write_data(a_reg),
        .read_data(mem_read_data),
        .mem20_debug(mem20_debug),
        .mem21_debug(mem21_debug),
        .mem22_debug(mem22_debug)
    );

    assign pc_next = pc_src ? imm : pc_out + 8'd1;

    assign pc_debug = pc_out;
    assign ins_debug = instr;
    assign opcode_debug = opcode;
    assign r1_addr_debug = r1_addr;
    assign r2_addr_debug = r2_addr;
    assign imm_debug = imm;
    assign state_debug = state;
    assign ir_we_debug = ir_we;
    assign ab_we_debug = ab_we;
    assign reg_we_debug = reg_we;
    assign mem_we_debug = mem_we;
    assign pc_we_debug = pc_we;
    assign pc_src_debug = pc_src;
    assign reg_data1_debug = reg_data1;
    assign reg_data2_debug = reg_data2;
    assign a_reg_debug = a_reg;
    assign b_reg_debug = b_reg;
    assign alu_result_debug = alu_result;

endmodule