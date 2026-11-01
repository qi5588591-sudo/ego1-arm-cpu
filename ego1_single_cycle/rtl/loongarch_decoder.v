`timescale 1ns / 1ps

// A documented LA32 instruction subset; opcode bits follow the official ISA.
module loongarch_decoder (
    input  wire [31:0] instruction,
    output wire        legal,
    output wire [4:0]  raddr1,
    output wire [4:0]  raddr2,
    output wire [4:0]  rd,
    output wire        reg_write,
    output reg  [3:0]  alu_op,
    output wire        use_imm,
    output wire [31:0] immediate,
    output wire        mem_read,
    output wire        mem_write,
    output wire [1:0]  branch_kind,
    output wire [31:0] branch_offset
);
    wire is_add   = (instruction[31:15] == 17'h00020);
    wire is_sub   = (instruction[31:15] == 17'h00022);
    wire is_and   = (instruction[31:15] == 17'h00029);
    wire is_or    = (instruction[31:15] == 17'h0002a);
    wire is_xor   = (instruction[31:15] == 17'h0002b);
    wire is_slli  = (instruction[31:15] == 17'h00081);
    wire is_srli  = (instruction[31:15] == 17'h00089);
    wire is_srai  = (instruction[31:15] == 17'h00091);
    wire is_addi  = (instruction[31:22] == 10'h00a);
    wire is_ld    = (instruction[31:22] == 10'h0a2);
    wire is_st    = (instruction[31:22] == 10'h0a6);
    wire is_lu12i = (instruction[31:25] == 7'h0a);
    wire is_b     = (instruction[31:26] == 6'h14);
    wire is_beq   = (instruction[31:26] == 6'h16);
    wire is_bne   = (instruction[31:26] == 6'h17);

    assign legal = is_add | is_sub | is_and | is_or | is_xor |
                   is_slli | is_srli | is_srai | is_addi | is_ld |
                   is_st | is_lu12i | is_b | is_beq | is_bne;
    assign raddr1 = instruction[9:5];
    // Store and conditional branches use rd as their second source register.
    assign raddr2 = (is_st | is_beq | is_bne) ? instruction[4:0]
                                             : instruction[14:10];
    assign rd = instruction[4:0];
    assign reg_write = is_add | is_sub | is_and | is_or | is_xor |
                       is_slli | is_srli | is_srai | is_addi | is_ld | is_lu12i;
    assign use_imm = is_slli | is_srli | is_srai | is_addi | is_ld | is_st | is_lu12i;
    assign immediate = is_lu12i ? {instruction[24:5], 12'd0} :
                       (is_slli | is_srli | is_srai) ? {27'd0, instruction[14:10]} :
                       {{20{instruction[21]}}, instruction[21:10]};
    assign mem_read = is_ld;
    assign mem_write = is_st;
    // 0: no branch, 1: B, 2: BEQ, 3: BNE.
    assign branch_kind = is_b ? 2'd1 : is_beq ? 2'd2 : is_bne ? 2'd3 : 2'd0;
    // LoongArch offsets are relative to the branch instruction's PC.
    // B uses a split offs26 field: instruction[9:0] followed by [25:10].
    assign branch_offset = is_b ?
        {{4{instruction[9]}}, instruction[9:0], instruction[25:10], 2'b00} :
        {{14{instruction[25]}}, instruction[25:10], 2'b00};

    always @(*) begin
        alu_op = 4'd0;
        if (is_sub)        alu_op = 4'd1;
        else if (is_and)   alu_op = 4'd2;
        else if (is_or)    alu_op = 4'd3;
        else if (is_xor)   alu_op = 4'd4;
        else if (is_slli)  alu_op = 4'd6;
        else if (is_srli)  alu_op = 4'd7;
        else if (is_srai)  alu_op = 4'd8;
        else if (is_lu12i) alu_op = 4'd11;
    end
endmodule
