`timescale 1ns / 1ps

module dmem(
    input clk,
    input rst,
    input mem_we,
    input [7:0] addr,
    input [15:0] write_data,
    output [15:0] read_data,
    output [15:0] mem8_debug,
    output [15:0] mem4_debug,
    output [15:0] mem6_debug,
    output [15:0] mem18_debug,
    output [15:0] mem20_debug
);

    reg [15:0] mem [0:255];
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 256; i = i + 1)
                mem[i] <= 16'd0;

            mem[8]  <= 16'd8;
            mem[4]  <= 16'd4;
            mem[6]  <= 16'd6;
            mem[18] <= 16'd8;
            mem[20] <= 16'd0;
        end else begin
            if (mem_we)
                mem[addr] <= write_data;
        end
    end

    assign read_data = mem[addr];

    assign mem8_debug  = mem[8];
    assign mem4_debug  = mem[4];
    assign mem6_debug  = mem[6];
    assign mem18_debug = mem[18];
    assign mem20_debug = mem[20];

endmodule