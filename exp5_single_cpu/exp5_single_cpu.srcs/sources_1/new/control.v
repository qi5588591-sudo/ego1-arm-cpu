`timescale 1ns / 1ps

module control(
    input [6:0] opcode,
    output reg wr_en,
    output reg [2:0] alu_op
);

    always @(*) begin
        case (opcode)
            7'd1: begin
                wr_en = 1'b1;
                alu_op = 3'd0;
            end
            default: begin
                wr_en = 1'b0;
                alu_op = 3'd0;
            end
        endcase
    end

endmodule