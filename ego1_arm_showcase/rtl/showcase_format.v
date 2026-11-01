`timescale 1ns/1ps
// Turns the recorded value of one showcase sample into six seven-segment
// bytes. kind: 1 = decimal, 2 = decimal, 3 = hex, 4 = NZCV, 5 = hex.
module showcase_format(
    input wire [31:0] value,
    input wire [2:0] kind,
    output reg [47:0] lanes      // leftmost digit in lanes[47:40]
);
    function [7:0] seg(input [3:0] d);
        case(d)
            4'd0: seg=8'h3f; 4'd1: seg=8'h06; 4'd2: seg=8'h5b; 4'd3: seg=8'h4f;
            4'd4: seg=8'h66; 4'd5: seg=8'h6d; 4'd6: seg=8'h7d; 4'd7: seg=8'h07;
            4'd8: seg=8'h7f; 4'd9: seg=8'h6f; 4'd10: seg=8'h77; 4'd11: seg=8'h7c;
            4'd12: seg=8'h39; 4'd13: seg=8'h5e; 4'd14: seg=8'h79; 4'd15: seg=8'h71;
        endcase
    endfunction
    reg negative;
    reg [31:0] absolute;
    reg [19:0] magnitude;
    reg [23:0] bcd;
    integer i;
    always @* begin
        negative = value[31];
        absolute = negative ? (~value + 32'd1) : value;
        magnitude = (absolute > 32'd99999) ? 20'd99999 : absolute[19:0];
        bcd = 24'd0;
        for(i=19;i>=0;i=i-1) begin
            if(bcd[3:0]>=4'd5) bcd[3:0]=bcd[3:0]+4'd3;
            if(bcd[7:4]>=4'd5) bcd[7:4]=bcd[7:4]+4'd3;
            if(bcd[11:8]>=4'd5) bcd[11:8]=bcd[11:8]+4'd3;
            if(bcd[15:12]>=4'd5) bcd[15:12]=bcd[15:12]+4'd3;
            if(bcd[19:16]>=4'd5) bcd[19:16]=bcd[19:16]+4'd3;
            if(bcd[23:20]>=4'd5) bcd[23:20]=bcd[23:20]+4'd3;
            bcd = {bcd[22:0],magnitude[i]};
        end
        if(kind==3'd4)
            lanes = {seg(4'd0),seg(4'd0),seg({3'd0,value[3]}),seg({3'd0,value[2]}),
                     seg({3'd0,value[1]}),seg({3'd0,value[0]})};
        else if(kind==3'd3||kind==3'd5||kind==3'd6)
            lanes = {seg(value[23:20]),seg(value[19:16]),seg(value[15:12]),
                     seg(value[11:8]),seg(value[7:4]),seg(value[3:0])};
        else
            lanes = {negative?8'h40:seg(bcd[23:20]),seg(bcd[19:16]),seg(bcd[15:12]),
                     seg(bcd[11:8]),seg(bcd[7:4]),seg(bcd[3:0])};
    end
endmodule

