module regfile(
    input wire clk,
    input wire rst,
    input wire wr_en,
    input wire [2:0] read_addr1,
    input wire [2:0] read_addr2,
    input wire [2:0] write_addr,
    input wire [15:0] write_data,
    output wire [15:0] read_data1,
    output wire [15:0] read_data2
);

reg [15:0] regs [0:7];
integer i;

assign read_data1 = regs[read_addr1];
assign read_data2 = regs[read_addr2];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 8; i = i + 1) begin
            regs[i] <= 16'b0;
        end
    end else begin
        if (wr_en) begin
            regs[write_addr] <= write_data;
        end
    end
end

endmodule