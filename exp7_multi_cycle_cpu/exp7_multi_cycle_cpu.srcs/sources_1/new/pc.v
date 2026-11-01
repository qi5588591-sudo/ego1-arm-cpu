`timescale 1ns / 1ps

module pc(
    input clk,
    input rst,
    input pc_we,
    input [7:0] pc_in,
    output reg [7:0] pc_out
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            pc_out <= 8'd0;
        else if (pc_we)
            pc_out <= pc_in;
    end

endmodule