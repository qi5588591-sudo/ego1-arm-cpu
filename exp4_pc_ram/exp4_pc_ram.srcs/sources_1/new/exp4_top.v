module exp4_top(
    input wire clk,
    input wire rst,
    input wire rw,
    input wire [8:0] ram_addr,
    input wire [15:0] ram_write_data,
    output wire [7:0] pc_out,
    output wire [15:0] ram_read_data
);

pc u_pc(
    .clk(clk),
    .rst(rst),
    .pc_out(pc_out)
);

ram u_ram(
    .clk(clk),
    .rst(rst),
    .rw(rw),
    .addr(ram_addr),
    .write_data(ram_write_data),
    .read_data(ram_read_data)
);

endmodule