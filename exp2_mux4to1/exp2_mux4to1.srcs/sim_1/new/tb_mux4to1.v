`timescale 1ns / 1ps

module tb_mux4to1;

    reg  [3:0] a;
    reg  [3:0] b;
    reg  [3:0] c;
    reg  [3:0] d;
    reg  [1:0] sel;

    wire [3:0] y;

    mux4to1 uut (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .sel(sel),
        .y(y)
    );

    initial begin
        a = 4'd8;
        b = 4'd4;
        c = 4'd6;
        d = 4'd8;

        sel = 2'd0;
        #100;

        sel = 2'd1;
        #100;

        sel = 2'd2;
        #100;

        sel = 2'd3;
        #100;

        $stop;
    end

endmodule