`timescale 1ns / 1ps

// 64 words = 256 bytes. Asynchronous read and synchronous write.
// Contents initialize on FPGA configuration and are retained on CPU reset.
module data_ram (
    input  wire        clk,
    input  wire        reset,
    input  wire        we,
    input  wire [31:0] address,
    input  wire [31:0] wdata,
    output wire [31:0] rdata,
    output wire        address_valid,
    output reg  [31:0] result_word,
    output reg  [31:0] sum_word,
    output reg  [31:0] status_word
);
    (* ram_style = "distributed" *) reg [31:0] memory [0:63];
    integer i;
    initial begin
        for (i = 0; i < 64; i = i + 1)
            memory[i] = 32'd0;
        result_word = 32'd0;
        sum_word = 32'd0;
        status_word = 32'd0;
    end

    assign address_valid = (address[31:8] == 24'd0) && (address[1:0] == 2'd0);
    assign rdata = address_valid ? memory[address[7:2]] : 32'd0;
    // Mirror three observed words on writes. Extra constant read ports would
    // prevent inference of a compact single-port distributed RAM.
    always @(posedge clk) begin
        if (!reset && we && address_valid) begin
            memory[address[7:2]] <= wdata;
            if (address == 32'd0) result_word <= wdata;
            if (address == 32'd4) sum_word <= wdata;
            if (address == 32'd8) status_word <= wdata;
        end
    end
endmodule
