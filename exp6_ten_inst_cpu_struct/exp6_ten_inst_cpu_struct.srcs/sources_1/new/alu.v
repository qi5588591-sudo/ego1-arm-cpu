`timescale 1ns / 1ps

module alu(
    input [15:0] acc_in,
    input [15:0] mem_data,
    input [3:0] alu_op,
    output reg [15:0] alu_result
);

    always @(*) begin
        case (alu_op)
            4'h0: alu_result = 16'd0;
            4'h1: alu_result = ~acc_in;
            4'h2: alu_result = acc_in >> 1;
            4'h3: alu_result = {acc_in[14:0], acc_in[15]};
            4'h5: alu_result = acc_in + mem_data;
            4'h7: alu_result = mem_data;
            default: alu_result = acc_in;
        endcase
    end

endmodule