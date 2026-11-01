`timescale 1ns / 1ps

module ab_reg(
    input clk,
    input rst,
    input ab_we,
    input [15:0] a_in,
    input [15:0] b_in,
    output reg [15:0] a_out,
    output reg [15:0] b_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_out <= 16'd0;
            b_out <= 16'd0;
        end else if (ab_we) begin
            a_out <= a_in;
            b_out <= b_in;
        end
    end

endmodule