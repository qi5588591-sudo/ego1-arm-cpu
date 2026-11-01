`timescale 1ns / 1ps

module alu(
    input [15:0] a,
    input [15:0] b,
    input [1:0] alu_op,
    output reg [15:0] result,
    output zero
);

    always @(*) begin
        case (alu_op)
            2'd0: result = a + b;
            2'd1: result = a - b;
            default: result = 16'd0;
        endcase
    end

    assign zero = (result == 16'd0);

endmodule