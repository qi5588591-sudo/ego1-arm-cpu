`timescale 1ns / 1ps

// Internal ALU operation numbers are control signals, not instruction encodings.
module alu32 (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_op,
    output reg  [31:0] result,
    output wire        zero
);
    localparam OP_ADD    = 4'd0;
    localparam OP_SUB    = 4'd1;
    localparam OP_AND    = 4'd2;
    localparam OP_OR     = 4'd3;
    localparam OP_XOR    = 4'd4;
    localparam OP_NOR    = 4'd5;
    localparam OP_SLL    = 4'd6;
    localparam OP_SRL    = 4'd7;
    localparam OP_SRA    = 4'd8;
    localparam OP_SLT    = 4'd9;
    localparam OP_SLTU   = 4'd10;
    localparam OP_PASS_B = 4'd11;

    always @(*) begin
        case (alu_op)
            OP_ADD:    result = a + b;
            OP_SUB:    result = a - b;
            OP_AND:    result = a & b;
            OP_OR:     result = a | b;
            OP_XOR:    result = a ^ b;
            OP_NOR:    result = ~(a | b);
            OP_SLL:    result = a << b[4:0];
            OP_SRL:    result = a >> b[4:0];
            OP_SRA:    result = $signed(a) >>> b[4:0];
            OP_SLT:    result = {31'd0, ($signed(a) < $signed(b))};
            OP_SLTU:   result = {31'd0, (a < b)};
            OP_PASS_B: result = b;
            default:   result = 32'd0;
        endcase
    end

    assign zero = (result == 32'd0);
endmodule
