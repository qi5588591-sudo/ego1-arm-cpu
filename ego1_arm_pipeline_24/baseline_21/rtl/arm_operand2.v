`timescale 1ns/1ps
// A32 immediate rotation and register shifted by an immediate (including RRX).
module arm_operand2(input wire immediate, input wire [11:0] encoding,
    input wire [31:0] rm_value, input wire carry_in,
    output reg [31:0] value, output reg carry_out);
    reg [31:0] base;
    integer amount;
    always @* begin
        value=rm_value; carry_out=carry_in; base=0; amount=0;
        if(immediate) begin
            base={24'd0,encoding[7:0]}; amount={encoding[11:8],1'b0};
            if(amount==0) value=base;
            else begin
                value=(base>>amount)|(base<<(32-amount));
                carry_out=value[31];
            end
        end else begin
            amount=encoding[11:7];
            case(encoding[6:5])
                0: if(amount!=0) begin
                    value=rm_value<<amount; carry_out=rm_value[32-amount];
                end
                1: if(amount==0) begin value=0; carry_out=rm_value[31]; end
                   else begin value=rm_value>>amount; carry_out=rm_value[amount-1]; end
                2: if(amount==0) begin value={32{rm_value[31]}}; carry_out=rm_value[31]; end
                   else begin value=$signed(rm_value)>>>amount; carry_out=rm_value[amount-1]; end
                3: if(amount==0) begin value={carry_in,rm_value[31:1]}; carry_out=rm_value[0]; end
                   else begin value=(rm_value>>amount)|(rm_value<<(32-amount)); carry_out=value[31]; end
            endcase
        end
    end
endmodule
