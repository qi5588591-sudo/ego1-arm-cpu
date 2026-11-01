`timescale 1ns / 1ps

module tb_cpu_top;

    reg clk;
    reg rst;

    wire [7:0] pc_debug;
    wire [15:0] ins_debug;
    wire [3:0] opcode_debug;
    wire [7:0] operand_debug;
    wire [15:0] acc_debug;
    wire [15:0] mem_data_debug;
    wire [15:0] alu_result_debug;
    wire acc_we_debug;
    wire mem_we_debug;
    wire jump_debug;
    wire branch_debug;
    wire halted_debug;
    wire [7:0] next_pc_debug;
    wire [15:0] mem8_debug;
    wire [15:0] mem4_debug;
    wire [15:0] mem6_debug;
    wire [15:0] mem18_debug;
    wire [15:0] mem20_debug;

    cpu_top uut (
        .clk(clk),
        .rst(rst),
        .pc_debug(pc_debug),
        .ins_debug(ins_debug),
        .opcode_debug(opcode_debug),
        .operand_debug(operand_debug),
        .acc_debug(acc_debug),
        .mem_data_debug(mem_data_debug),
        .alu_result_debug(alu_result_debug),
        .acc_we_debug(acc_we_debug),
        .mem_we_debug(mem_we_debug),
        .jump_debug(jump_debug),
        .branch_debug(branch_debug),
        .halted_debug(halted_debug),
        .next_pc_debug(next_pc_debug),
        .mem8_debug(mem8_debug),
        .mem4_debug(mem4_debug),
        .mem6_debug(mem6_debug),
        .mem18_debug(mem18_debug),
        .mem20_debug(mem20_debug)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst = 1;
        #25;

        rst = 0;
        #400;

        $stop;
    end

endmodule