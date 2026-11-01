`timescale 1ns / 1ps

module tb_single_cpu;

    reg clk;
    reg rst;

    wire [7:0] pc_debug;
    wire [15:0] ins_debug;
    wire [6:0] opcode_debug;
    wire [2:0] r1_addr_debug;
    wire [2:0] r2_addr_debug;
    wire [2:0] r3_addr_debug;
    wire wr_en_debug;
    wire [15:0] reg_data1_debug;
    wire [15:0] reg_data2_debug;
    wire [15:0] alu_result_debug;
    wire [15:0] r1_debug;
    wire [15:0] r2_debug;
    wire [15:0] r3_debug;
    wire [15:0] r4_debug;
    wire [15:0] r5_debug;
    wire [15:0] r6_debug;
    wire [15:0] r7_debug;

    single_cpu uut (
        .clk(clk),
        .rst(rst),
        .pc_debug(pc_debug),
        .ins_debug(ins_debug),
        .opcode_debug(opcode_debug),
        .r1_addr_debug(r1_addr_debug),
        .r2_addr_debug(r2_addr_debug),
        .r3_addr_debug(r3_addr_debug),
        .wr_en_debug(wr_en_debug),
        .reg_data1_debug(reg_data1_debug),
        .reg_data2_debug(reg_data2_debug),
        .alu_result_debug(alu_result_debug),
        .r1_debug(r1_debug),
        .r2_debug(r2_debug),
        .r3_debug(r3_debug),
        .r4_debug(r4_debug),
        .r5_debug(r5_debug),
        .r6_debug(r6_debug),
        .r7_debug(r7_debug)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst = 1;
        #25;

        rst = 0;
        #200;

        $stop;
    end

endmodule