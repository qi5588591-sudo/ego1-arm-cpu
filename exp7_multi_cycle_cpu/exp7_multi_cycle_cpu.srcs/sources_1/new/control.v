`timescale 1ns / 1ps

module control(
    input clk,
    input rst,
    input [3:0] opcode,
    output reg ir_we,
    output reg ab_we,
    output reg reg_we,
    output reg mem_we,
    output reg pc_we,
    output reg pc_src,
    output reg [1:0] alu_op,
    output reg [1:0] state_debug
);

    parameter FI  = 2'd0;
    parameter ID  = 2'd1;
    parameter EXE = 2'd2;

    reg [1:0] state;
    reg [1:0] next_state;

    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= FI;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            FI: next_state = ID;
            ID: next_state = EXE;
            EXE: next_state = FI;
            default: next_state = FI;
        endcase
    end

    always @(*) begin
        ir_we = 1'b0;
        ab_we = 1'b0;
        reg_we = 1'b0;
        mem_we = 1'b0;
        pc_we = 1'b0;
        pc_src = 1'b0;
        alu_op = 2'd0;
        state_debug = state;

        case (state)
            FI: begin
                ir_we = 1'b1;
            end

            ID: begin
                ab_we = 1'b1;
            end

            EXE: begin
                pc_we = 1'b1;

                case (opcode)
                    4'h1: begin
                        reg_we = 1'b1;
                        alu_op = 2'd0;
                        pc_src = 1'b0;
                    end

                    4'h2: begin
                        mem_we = 1'b1;
                        pc_src = 1'b0;
                    end

                    4'h3: begin
                        pc_src = 1'b1;
                    end

                    default: begin
                        pc_src = 1'b0;
                    end
                endcase
            end

            default: begin
                ir_we = 1'b0;
                ab_we = 1'b0;
                reg_we = 1'b0;
                mem_we = 1'b0;
                pc_we = 1'b0;
                pc_src = 1'b0;
                alu_op = 2'd0;
                state_debug = FI;
            end
        endcase
    end

endmodule