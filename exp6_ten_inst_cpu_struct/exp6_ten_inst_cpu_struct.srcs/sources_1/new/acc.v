`timescale 1ns / 1ps

module acc(
    input clk,
    input rst,
    input acc_we,
    input [15:0] acc_in,
    output reg [15:0] acc_out
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            acc_out <= 16'd0;
        else if (acc_we)
            acc_out <= acc_in;
    end

endmodule