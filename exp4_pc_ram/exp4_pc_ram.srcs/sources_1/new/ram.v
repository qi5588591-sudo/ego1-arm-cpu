`timescale 1ns / 1ps

module ram(
    input clk,
    input rst,
    input rw,
    input [7:0] addr,
    input [15:0] write_data,
    output [15:0] read_data
);

    reg [15:0] mem [0:255];
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 256; i = i + 1) begin
                mem[i] <= 16'd0;
            end
        end else begin
            if (rw) begin
                mem[addr] <= write_data;
            end
        end
    end

    assign read_data = mem[addr];

endmodule