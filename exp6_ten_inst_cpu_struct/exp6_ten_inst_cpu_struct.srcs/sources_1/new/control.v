`timescale 1ns / 1ps

module control(
    input [3:0] opcode,
    input acc_negative,
    output reg acc_we,
    output reg mem_we,
    output reg jump,
    output reg branch,
    output reg halt,
    output reg [3:0] alu_op
);

    always @(*) begin
        acc_we = 1'b0;
        mem_we = 1'b0;
        jump = 1'b0;
        branch = 1'b0;
        halt = 1'b0;
        alu_op = opcode;

        case (opcode)
            4'h0: begin
                acc_we = 1'b1;
                alu_op = 4'h0;
            end

            4'h1: begin
                acc_we = 1'b1;
                alu_op = 4'h1;
            end

            4'h2: begin
                acc_we = 1'b1;
                alu_op = 4'h2;
            end

            4'h3: begin
                acc_we = 1'b1;
                alu_op = 4'h3;
            end

            4'h4: begin
                halt = 1'b1;
            end

            4'h5: begin
                acc_we = 1'b1;
                alu_op = 4'h5;
            end

            4'h6: begin
                mem_we = 1'b1;
            end

            4'h7: begin
                acc_we = 1'b1;
                alu_op = 4'h7;
            end

            4'h8: begin
                jump = 1'b1;
            end

            4'h9: begin
                if (acc_negative)
                    branch = 1'b1;
            end

            default: begin
                acc_we = 1'b0;
                mem_we = 1'b0;
                jump = 1'b0;
                branch = 1'b0;
                halt = 1'b0;
                alu_op = 4'h0;
            end
        endcase
    end

endmodule