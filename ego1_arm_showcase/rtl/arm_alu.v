`timescale 1ns/1ps
// Opcode is the actual A32 data-processing opcode, not a custom ISA encoding.
module arm_alu(input wire [3:0] opcode, input wire [31:0] a,b,
    input wire [3:0] old_flags, input wire shifter_carry,
    output reg [31:0] result, output reg [3:0] new_flags);
    reg arithmetic, cin;
    reg [31:0] x,y;
    reg [32:0] sum;
    always @* begin
        result=0; x=a; y=b; cin=0; arithmetic=0; sum=0;
        case(opcode)
            4'h0,4'h8: result=a&b;
            4'h1: result=a^b;
            4'h2,4'ha: begin arithmetic=1; y=~b; cin=1; end
            4'h3: begin arithmetic=1; x=b; y=~a; cin=1; end
            4'h4,4'hb: arithmetic=1;
            4'h5: begin arithmetic=1; cin=old_flags[1]; end
            4'h6: begin arithmetic=1; y=~b; cin=old_flags[1]; end
            4'hc: result=a|b;
            4'hd: result=b;
            4'he: result=a&~b;
            4'hf: result=~b;
            default: result=0;
        endcase
        new_flags=old_flags;
        if(arithmetic) begin
            sum={1'b0,x}+{1'b0,y}+{32'd0,cin}; result=sum[31:0];
            new_flags[1]=sum[32];
            new_flags[0]=(x[31]==y[31])&&(result[31]!=x[31]);
        end else new_flags[1]=shifter_carry;
        new_flags[3]=result[31]; new_flags[2]=(result==0);
    end
endmodule
