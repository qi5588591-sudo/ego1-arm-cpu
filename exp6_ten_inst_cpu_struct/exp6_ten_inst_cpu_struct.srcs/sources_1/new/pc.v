`timescale 1ns / 1ps

module pc(
    input clk,
    input rst,
    input halt,
    input [7:0] next_pc,
    output reg [7:0] pc_out
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            pc_out <= 8'd0;
        else if (!halt)
            pc_out <= next_pc;
    end

endmodule