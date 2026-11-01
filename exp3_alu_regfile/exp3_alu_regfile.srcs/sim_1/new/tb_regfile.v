`timescale 1ns / 1ps

module tb_regfile;

    reg clk;
    reg rst;
    reg wr_en;

    reg  [2:0]  read_addr1;
    reg  [2:0]  read_addr2;
    reg  [2:0]  write_addr;
    reg  [15:0] write_data;

    wire [15:0] read_data1;
    wire [15:0] read_data2;

    regfile uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .write_addr(write_addr),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst = 1;
        wr_en = 0;
        read_addr1 = 3'd0;
        read_addr2 = 3'd0;
        write_addr = 3'd0;
        write_data = 16'd0;

        #25;
        rst = 0;

        #15;
        wr_en = 1;
        write_addr = 3'd1;
        write_data = 16'd8;
        #20;

        write_addr = 3'd2;
        write_data = 16'd4;
        #20;

        write_addr = 3'd3;
        write_data = 16'd6;
        #20;

        write_addr = 3'd4;
        write_data = 16'd8;
        #20;

        wr_en = 0;

        read_addr1 = 3'd1;
        read_addr2 = 3'd2;
        #40;

        read_addr1 = 3'd3;
        read_addr2 = 3'd4;
        #40;

        read_addr1 = 3'd1;
        read_addr2 = 3'd4;
        #40;

        read_addr1 = 3'd2;
        read_addr2 = 3'd3;
        #40;

        $stop;
    end

endmodule