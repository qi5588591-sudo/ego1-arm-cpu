module exp3_top(
    input wire clk,
    input wire rst,
    input wire wr_en,
    input wire [2:0] read_addr1,
    input wire [2:0] read_addr2,
    input wire [2:0] write_addr,
    input wire [15:0] write_data,
    input wire [2:0] alu_op,
    output wire [15:0] read_data1,
    output wire [15:0] read_data2,
    output wire [15:0] alu_result,
    output wire zero
);

regfile u_regfile(
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .read_addr1(read_addr1),
    .read_addr2(read_addr2),
    .write_addr(write_addr),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

alu u_alu(
    .a(read_data1),
    .b(read_data2),
    .alu_op(alu_op),
    .result(alu_result),
    .zero(zero)
);

endmodule