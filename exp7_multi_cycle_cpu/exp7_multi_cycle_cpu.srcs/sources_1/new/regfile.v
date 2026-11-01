`timescale 1ns / 1ps

module regfile(
    input clk,
    input rst,
    input reg_we,
    input [2:0] read_addr1,
    input [2:0] read_addr2,
    input [2:0] write_addr,
    input [15:0] write_data,
    output [15:0] read_data1,
    output [15:0] read_data2,
    output [15:0] r1_debug,
    output [15:0] r2_debug,
    output [15:0] r3_debug,
    output [15:0] r4_debug,
    output [15:0] r5_debug,
    output [15:0] r6_debug,
    output [15:0] r7_debug
);

    reg [15:0] regs [0:7];
    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8; i = i + 1)
                regs[i] <= 16'd0;

            regs[1] <= 16'd8;
            regs[2] <= 16'd4;
            regs[6] <= 16'd6;
            regs[7] <= 16'd8;
        end else begin
            if (reg_we)
                regs[write_addr] <= write_data;
        end
    end

    assign read_data1 = regs[read_addr1];
    assign read_data2 = regs[read_addr2];

    assign r1_debug = regs[1];
    assign r2_debug = regs[2];
    assign r3_debug = regs[3];
    assign r4_debug = regs[4];
    assign r5_debug = regs[5];
    assign r6_debug = regs[6];
    assign r7_debug = regs[7];

endmodule