`timescale 1ns/1ps
module arm_regfile(input wire clk,reset,we,input wire [3:0] ra,rb,wd,
    input wire [31:0] wdata,pc,output wire [31:0] a,b);
    reg [31:0] regs[0:14];
    integer i;
    assign a=(ra==15)?pc+32'd8:regs[ra];
    assign b=(rb==15)?pc+32'd8:regs[rb];
    always @(posedge clk) begin
        if(reset) for(i=0;i<15;i=i+1) regs[i]<=0;
        else if(we && wd!=15) regs[wd]<=wdata;
    end
endmodule
