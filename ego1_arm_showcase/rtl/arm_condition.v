`timescale 1ns/1ps
module arm_condition(input wire [3:0] cond, nzcv, output reg passed);
    wire n=nzcv[3], z=nzcv[2], c=nzcv[1], v=nzcv[0];
    always @* case(cond)
        0: passed=z;        1: passed=!z;
        2: passed=c;        3: passed=!c;
        4: passed=n;        5: passed=!n;
        6: passed=v;        7: passed=!v;
        8: passed=c&&!z;    9: passed=!c||z;
        10: passed=n==v;    11: passed=n!=v;
        12: passed=!z&&(n==v); 13: passed=z||(n!=v);
        14: passed=1'b1;    default: passed=1'b0;
    endcase
endmodule
