`timescale 1ns/1ps
// Fixed 32-iteration shift/add multiply and restoring divide.
// op: 0=MUL low 32 bits, 1=SDIV, 2=UDIV. One request at a time.
module arm_mdu(
    input wire clk,reset,start,
    input wire [1:0] op,
    input wire [31:0] a,b,
    output reg busy,done,
    output reg [31:0] result
);
    reg [1:0] operation;
    reg [5:0] remaining;
    reg [31:0] product,multiplicand,multiplier;
    reg [31:0] quotient,divisor;
    reg [32:0] remainder;
    reg negate,divide_zero;
    wire [31:0] abs_a=(op==1 && a[31]) ? (~a+32'd1) : a;
    wire [31:0] abs_b=(op==1 && b[31]) ? (~b+32'd1) : b;
    wire [31:0] product_next=product+(multiplier[0]?multiplicand:32'd0);
    wire [32:0] shifted_remainder={remainder[31:0],quotient[31]};
    wire subtract_divisor=shifted_remainder>={1'b0,divisor};
    wire [32:0] remainder_next=subtract_divisor?
        shifted_remainder-{1'b0,divisor}:shifted_remainder;
    wire [31:0] quotient_next={quotient[30:0],subtract_divisor};
    always @(posedge clk) begin
        if(reset) begin
            busy<=0;done<=0;result<=0;operation<=0;remaining<=0;
            product<=0;multiplicand<=0;multiplier<=0;
            quotient<=0;divisor<=0;remainder<=0;negate<=0;divide_zero<=0;
        end else begin
            done<=0;
            if(start&&!busy) begin
                busy<=1;operation<=op;remaining<=32;
                product<=0;multiplicand<=a;multiplier<=b;
                quotient<=abs_a;divisor<=abs_b;remainder<=0;
                negate<=(op==1)&&(a[31]^b[31]);divide_zero<=(b==0);
            end else if(busy) begin
                remaining<=remaining-1'b1;
                if(operation==0) begin
                    product<=product_next;
                    multiplicand<=multiplicand<<1;multiplier<=multiplier>>1;
                    if(remaining==1) result<=product_next;
                end else begin
                    remainder<=remainder_next;quotient<=quotient_next;
                    if(remaining==1)
                        result<=divide_zero?32'd0:negate?(~quotient_next+32'd1):quotient_next;
                end
                if(remaining==1) begin busy<=0;done<=1;end
            end
        end
    end
endmodule
