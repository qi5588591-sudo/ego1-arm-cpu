`timescale 1ns / 1ps

module ir(
    input clk,
    input rst,
    input ir_we,
    input [15:0] instr_in,
    output reg [15:0] instr_out
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            instr_out <= 16'd0;
        else if (ir_we)
            instr_out <= instr_in;
    end

endmodule