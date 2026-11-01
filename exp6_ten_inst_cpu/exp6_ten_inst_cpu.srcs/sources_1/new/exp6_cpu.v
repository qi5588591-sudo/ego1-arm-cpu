module exp6_cpu(
    input wire clk,
    input wire rst,

    output wire [7:0] pc_debug,
    output wire [15:0] ins_debug,
    output wire [3:0] opcode_debug,
    output wire [11:0] operand_debug,
    output wire [15:0] acc_debug,
    output wire halted_debug,

    output wire [15:0] mem10_debug,
    output wire [15:0] mem11_debug,
    output wire [15:0] mem12_debug,
    output wire [15:0] mem20_debug
);

localparam OP_CLA = 4'b0000;
localparam OP_COM = 4'b0001;
localparam OP_SHR = 4'b0010;
localparam OP_CSL = 4'b0011;
localparam OP_STP = 4'b0100;
localparam OP_ADD = 4'b0101;
localparam OP_STA = 4'b0110;
localparam OP_LDA = 4'b0111;
localparam OP_JMP = 4'b1000;
localparam OP_BAN = 4'b1001;

reg [7:0] pc;
reg [15:0] acc;
reg halted;

reg [15:0] imem [0:255];
reg [15:0] dmem [0:255];

wire [15:0] ins;
wire [3:0] opcode;
wire [11:0] operand;
wire [7:0] addr;

wire signed [8:0] pc_signed;
wire signed [8:0] offset_signed;
wire signed [8:0] ban_sum;

integer i;

assign ins = imem[pc];
assign opcode = ins[15:12];
assign operand = ins[11:0];
assign addr = operand[7:0];

assign pc_signed = {1'b0, pc};
assign offset_signed = {operand[7], operand[7:0]};
assign ban_sum = pc_signed + offset_signed;

assign pc_debug = pc;
assign ins_debug = ins;
assign opcode_debug = opcode;
assign operand_debug = operand;
assign acc_debug = acc;
assign halted_debug = halted;

assign mem10_debug = dmem[8'd10];
assign mem11_debug = dmem[8'd11];
assign mem12_debug = dmem[8'd12];
assign mem20_debug = dmem[8'd20];

initial begin
    for (i = 0; i < 256; i = i + 1) begin
        imem[i] = 16'b0;
        dmem[i] = 16'b0;
    end

    // 数据初始化
    dmem[8'd10] = 16'd5;
    dmem[8'd11] = 16'd3;
    dmem[8'd12] = 16'd16;

    // 程序：
    // 0: CLA           ACC = 0
    // 1: LDA 10        ACC = mem[10] = 5
    // 2: ADD 11        ACC = 5 + mem[11] = 8
    // 3: STA 20        mem[20] = 8
    // 4: COM           ACC = ~8 = 0xfff7，负数
    // 5: SHR           ACC 算术右移
    // 6: CSL           ACC 循环左移
    // 7: BAN +2        ACC 为负，跳到 9，跳过 8
    // 8: CLA           被跳过
    // 9: LDA 12        ACC = 16
    // 10: BAN +2       ACC 非负，不跳，继续执行 11
    // 11: SHR          ACC = 8
    // 12: JMP 14       跳到 14，跳过 13
    // 13: COM          被跳过
    // 14: STP          停机

    imem[8'd0]  = {OP_CLA, 12'd0};
    imem[8'd1]  = {OP_LDA, 12'd10};
    imem[8'd2]  = {OP_ADD, 12'd11};
    imem[8'd3]  = {OP_STA, 12'd20};
    imem[8'd4]  = {OP_COM, 12'd0};
    imem[8'd5]  = {OP_SHR, 12'd0};
    imem[8'd6]  = {OP_CSL, 12'd0};
    imem[8'd7]  = {OP_BAN, 12'd2};
    imem[8'd8]  = {OP_CLA, 12'd0};
    imem[8'd9]  = {OP_LDA, 12'd12};
    imem[8'd10] = {OP_BAN, 12'd2};
    imem[8'd11] = {OP_SHR, 12'd0};
    imem[8'd12] = {OP_JMP, 12'd14};
    imem[8'd13] = {OP_COM, 12'd0};
    imem[8'd14] = {OP_STP, 12'd0};
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        pc <= 8'd0;
        acc <= 16'd0;
        halted <= 1'b0;

        // 复位数据区，保证重复仿真结果稳定
        for (i = 0; i < 256; i = i + 1) begin
            dmem[i] <= 16'b0;
        end

        dmem[8'd10] <= 16'd5;
        dmem[8'd11] <= 16'd3;
        dmem[8'd12] <= 16'd16;
    end else begin
        if (!halted) begin
            case (opcode)
                OP_CLA: begin
                    acc <= 16'd0;
                    pc <= pc + 1'b1;
                end

                OP_COM: begin
                    acc <= ~acc;
                    pc <= pc + 1'b1;
                end

                OP_SHR: begin
                    acc <= {acc[15], acc[15:1]};
                    pc <= pc + 1'b1;
                end

                OP_CSL: begin
                    acc <= {acc[14:0], acc[15]};
                    pc <= pc + 1'b1;
                end

                OP_STP: begin
                    halted <= 1'b1;
                    pc <= pc;
                end

                OP_ADD: begin
                    acc <= acc + dmem[addr];
                    pc <= pc + 1'b1;
                end

                OP_STA: begin
                    dmem[addr] <= acc;
                    pc <= pc + 1'b1;
                end

                OP_LDA: begin
                    acc <= dmem[addr];
                    pc <= pc + 1'b1;
                end

                OP_JMP: begin
                    pc <= addr;
                end

                OP_BAN: begin
                    if (acc[15] == 1'b1)
                        pc <= ban_sum[7:0];
                    else
                        pc <= pc + 1'b1;
                end

                default: begin
                    pc <= pc + 1'b1;
                end
            endcase
        end
    end
end

endmodule