`timescale 1ns / 1ps

module tb_pc;

    reg clk;
    reg rst;

    wire [7:0] pc_out;

    pc uut (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst = 1;
        #25;

        rst = 0;
        #200;

        rst = 1;
        #20;

        rst = 0;
        #200;

        $stop;
    end

endmodule