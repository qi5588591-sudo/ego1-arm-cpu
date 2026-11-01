`timescale 1ns / 1ps

module tb_cpu_top;

    reg clk;
    reg rst;

    wire [7:0] pc_debug;
    wire [15:0] ins_debug;
    wire [3:0] opcode_debug;
    wire [2:0] r1_addr_debug;
    wire [2:0] r2_addr_debug;
    wire [7:0] imm_debug;
    wire [1:0] state_debug;
    wire ir_we_debug;
    wire ab_we_debug;
    wire reg_we_debug;
    wire mem_we_debug;
    wire pc_we_debug;
    wire pc_src_debug;
    wire [15:0] reg_data1_debug;
    wire [15:0] reg_data2_debug;
    wire [15:0] a_reg_debug;
    wire [15:0] b_reg_debug;
    wire [15:0] alu_result_debug;
    wire [15:0] r1_debug;
    wire [15:0] r2_debug;
    wire [15:0] r3_debug;
    wire [15:0] r4_debug;
    wire [15:0] r5_debug;
    wire [15:0] r6_debug;
    wire [15:0] r7_debug;
    wire [15:0] mem20_debug;
    wire [15:0] mem21_debug;
    wire [15:0] mem22_debug;

    cpu_top uut (
        .clk(clk),
        .rst(rst),
        .pc_debug(pc_debug),
        .ins_debug(ins_debug),
        .opcode_debug(opcode_debug),
        .r1_addr_debug(r1_addr_debug),
        .r2_addr_debug(r2_addr_debug),
        .imm_debug(imm_debug),
        .state_debug(state_debug),
        .ir_we_debug(ir_we_debug),
        .ab_we_debug(ab_we_debug),
        .reg_we_debug(reg_we_debug),
        .mem_we_debug(mem_we_debug),
        .pc_we_debug(pc_we_debug),
        .pc_src_debug(pc_src_debug),
        .reg_data1_debug(reg_data1_debug),
        .reg_data2_debug(reg_data2_debug),
        .a_reg_debug(a_reg_debug),
        .b_reg_debug(b_reg_debug),
        .alu_result_debug(alu_result_debug),
        .r1_debug(r1_debug),
        .r2_debug(r2_debug),
        .r3_debug(r3_debug),
        .r4_debug(r4_debug),
        .r5_debug(r5_debug),
        .r6_debug(r6_debug),
        .r7_debug(r7_debug),
        .mem20_debug(mem20_debug),
        .mem21_debug(mem21_debug),
        .mem22_debug(mem22_debug)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst = 1;
        #25;

        rst = 0;
        #800;

        $stop;
    end

endmodule