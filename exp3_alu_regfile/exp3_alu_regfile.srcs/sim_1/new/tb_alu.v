`timescale 1ns / 1ps

module tb_alu;

    reg  [15:0] a;
    reg  [15:0] b;
    reg  [2:0]  alu_op;

    wire [15:0] result;
    wire        zero;

    alu uut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result),
        .zero(zero)
    );

    initial begin
        a = 16'd8468;
        b = 16'd2024;

        alu_op = 3'd0;
        #100;

        alu_op = 3'd1;
        #100;

        alu_op = 3'd2;
        #100;

        alu_op = 3'd3;
        #100;

        alu_op = 3'd4;
        #100;

        alu_op = 3'd5;
        #100;

        a = 16'd8468;
        b = 16'd8468;
        alu_op = 3'd1;
        #100;

        $stop;
    end

endmodule