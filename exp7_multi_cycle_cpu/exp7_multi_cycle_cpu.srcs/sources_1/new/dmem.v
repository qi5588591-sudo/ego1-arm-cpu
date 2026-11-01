`timescale 1ns / 1ps

module dmem(
    input clk,
    input rst,
    input mem_we,
    input [7:0] addr,
    input [15:0] write_data,
    output [15:0] read_data,
    output [15:0] mem20_debug,
    output [15:0] mem21_debug,
    output [15:0] mem22_debug
);

    reg [15:0] mem [0:255];
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 256; i = i + 1)
                mem[i] <= 16'd0;
        end else begin
            if (mem_we)
                mem[addr] <= write_data;
        end
    end

    assign read_data = mem[addr];

    assign mem20_debug = mem[20];
    assign mem21_debug = mem[21];
    assign mem22_debug = mem[22];

endmodule