`timescale 1ns / 1ps

// Simulation-stage datapath: register operands feed the combinational ALU.
// Writeback is supplied externally; PC, decoder and memory come later.
module datapath_basics (
    input  wire        clk,
    input  wire        reset,
    input  wire        we,
    input  wire [4:0]  waddr,
    input  wire [31:0] wdata,
    input  wire [4:0]  raddr1,
    input  wire [4:0]  raddr2,
    input  wire [3:0]  alu_op,
    output wire [31:0] rdata1,
    output wire [31:0] rdata2,
    output wire [31:0] alu_result,
    output wire        zero
);
    regfile32 u_regfile (
        .clk(clk), .reset(reset), .we(we),
        .waddr(waddr), .wdata(wdata),
        .raddr1(raddr1), .raddr2(raddr2),
        .rdata1(rdata1), .rdata2(rdata2)
    );

    alu32 u_alu (
        .a(rdata1), .b(rdata2), .alu_op(alu_op),
        .result(alu_result), .zero(zero)
    );
endmodule
