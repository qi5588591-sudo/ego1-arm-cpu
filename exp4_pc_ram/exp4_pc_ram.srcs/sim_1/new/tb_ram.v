`timescale 1ns / 1ps

module tb_ram;

    reg clk;
    reg rst;
    reg rw;

    reg  [7:0]  addr;
    reg  [15:0] write_data;

    wire [15:0] read_data;

    ram uut (
        .clk(clk),
        .rst(rst),
        .rw(rw),
        .addr(addr),
        .write_data(write_data),
        .read_data(read_data)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst = 1;
        rw = 0;
        addr = 8'd0;
        write_data = 16'd0;

        #25;
        rst = 0;

        #15;
        rw = 1;
        addr = 8'd8;
        write_data = 16'd8468;
        #20;

        addr = 8'd4;
        write_data = 16'd2024;
        #20;

        addr = 8'd6;
        write_data = 16'd468;
        #20;

        rw = 0;
        write_data = 16'd0;

        addr = 8'd8;
        #40;

        addr = 8'd4;
        #40;

        addr = 8'd6;
        #40;

        addr = 8'd8;
        #40;

        $stop;
    end

endmodule