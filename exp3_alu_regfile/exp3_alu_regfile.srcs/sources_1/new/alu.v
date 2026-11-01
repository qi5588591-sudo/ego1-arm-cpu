module alu(
    input wire [15:0] a,
    input wire [15:0] b,
    input wire [2:0] alu_op,
    output reg [15:0] result,
    output wire zero
);

assign zero = (result == 16'b0);

always @(*) begin
    case (alu_op)
        3'b000: result = a + b;        // 加法
        3'b001: result = a - b;        // 减法
        3'b010: result = a & b;        // 按位与
        3'b011: result = a | b;        // 按位或
        3'b100: result = a << 1;       // 逻辑左移 1 位
        3'b101: result = a >> 1;       // 逻辑右移 1 位
        default: result = 16'b0;
    endcase
end

endmodule