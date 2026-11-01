module pc(
    input wire clk,
    input wire rst,
    output reg [7:0] pc_out
);

always @(posedge clk or posedge rst) begin
    if (rst)
        pc_out <= 8'b0000_0000;
    else
        pc_out <= pc_out + 1'b1;
end

endmodule