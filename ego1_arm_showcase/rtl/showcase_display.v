`timescale 1ns/1ps
// Scans eight pre-decoded seven-segment bytes onto the multiplexed display.
// lanes[63:56] is the leftmost digit; both segment banks are identical.
module showcase_display #(parameter integer SCAN_TICKS=250)(
    input wire clk,input wire [63:0] lanes,
    output reg [7:0] digit=0,output reg [7:0] segment0=0,segment1=0);
    reg [31:0] ticks=0;
    reg [2:0] position=0;
    reg blank=1;
    always @(posedge clk) begin
        if(ticks==SCAN_TICKS-1) begin ticks<=0;position<=position+1;blank<=1;digit<=0;end
        else begin
            ticks<=ticks+1;
            if(blank) begin
                segment0<=lanes[(7-position)*8 +: 8];
                segment1<=lanes[(7-position)*8 +: 8];
                blank<=0;
            end else digit<=8'b1<<position;
        end
    end
endmodule
