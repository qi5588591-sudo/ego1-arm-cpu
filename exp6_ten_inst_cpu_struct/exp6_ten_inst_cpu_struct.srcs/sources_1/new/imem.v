`timescale 1ns / 1ps

module imem(
    input [7:0] addr,
    output reg [15:0] instr
);

    always @(*) begin
        case (addr)
            8'd0:  instr = 16'h0000;
            8'd1:  instr = 16'h7008;
            8'd2:  instr = 16'h5004;
            8'd3:  instr = 16'h5006;
            8'd4:  instr = 16'h5012;
            8'd5:  instr = 16'h6014;
            8'd6:  instr = 16'h8008;
            8'd7:  instr = 16'h7000;
            8'd8:  instr = 16'h1000;
            8'd9:  instr = 16'h2000;
            8'd10: instr = 16'h3000;
            8'd11: instr = 16'h900D;
            8'd12: instr = 16'h7000;
            8'd13: instr = 16'h7014;
            8'd14: instr = 16'h4000;
            default: instr = 16'h4000;
        endcase
    end

endmodule