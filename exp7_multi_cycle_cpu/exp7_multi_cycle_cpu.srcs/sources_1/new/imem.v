`timescale 1ns / 1ps

module imem(
    input [7:0] addr,
    output reg [15:0] instr
);

    always @(*) begin
        case (addr)
            8'd0: instr = 16'h1280;
            8'd1: instr = 16'h2214;
            8'd2: instr = 16'h3004;
            8'd3: instr = 16'h16c0;
            8'd4: instr = 16'h1380;
            8'd5: instr = 16'h2215;
            8'd6: instr = 16'h13c0;
            8'd7: instr = 16'h2216;
            8'd8: instr = 16'h3008;
            default: instr = 16'h3008;
        endcase
    end

endmodule