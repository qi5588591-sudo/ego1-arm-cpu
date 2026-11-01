`timescale 1ns / 1ps

module tb_exp6_cpu;

reg clk;
reg rst;

wire [7:0] pc_debug;
wire [15:0] ins_debug;
wire [3:0] opcode_debug;
wire [11:0] operand_debug;
wire [15:0] acc_debug;
wire halted_debug;

wire [15:0] mem10_debug;
wire [15:0] mem11_debug;
wire [15:0] mem12_debug;
wire [15:0] mem20_debug;

exp6_cpu uut(
    .clk(clk),
    .rst(rst),

    .pc_debug(pc_debug),
    .ins_debug(ins_debug),
    .opcode_debug(opcode_debug),
    .operand_debug(operand_debug),
    .acc_debug(acc_debug),
    .halted_debug(halted_debug),

    .mem10_debug(mem10_debug),
    .mem11_debug(mem11_debug),
    .mem12_debug(mem12_debug),
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