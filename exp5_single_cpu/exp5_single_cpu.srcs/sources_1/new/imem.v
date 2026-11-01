`timescale 1ns / 1ps

module imem(
    input [7:0] addr,
    output reg [15:0] instr
);

    always @(*) begin
        case (addr)
            8'd0: instr = 16'h0253;
            8'd1: instr = 16'h02f4;
            8'd2: instr = 16'h033d;
            default: instr = 16'h0000;
        endcase
    end

endmodule