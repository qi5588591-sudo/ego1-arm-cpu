`timescale 1ns / 1ps

module pc(
    input clk,
    input rst,
    output reg [7:0] pc_out
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            pc_out <= 8'd0;
        else
            pc_out <= pc_out + 8'd1;
    end

endmodule