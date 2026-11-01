`timescale 1ns / 1ps

module tb_single_cycle_cpu;
    reg clk = 1'b0;
    reg reset = 1'b1;
    wire [31:0] pc, instruction, next_pc, result_word, sum_word, status_word;
    wire fault, trace_valid, trace_rd_we, trace_mem_req, trace_mem_we, trace_branch_taken;
    wire [31:0] trace_pc, trace_instruction, trace_next_pc, trace_wdata;
    wire [31:0] trace_mem_addr, trace_mem_wdata;
    wire [4:0] trace_rd;
    wire fault_tests_done;
    wire [31:0] fault_checks;
    integer retired = 0;
    integer checks = 0;

    always #5 clk = ~clk;

    single_cycle_soc dut (
        .clk(clk), .reset(reset), .pc(pc), .instruction(instruction), .next_pc(next_pc),
        .fault(fault), .result_word(result_word), .sum_word(sum_word), .status_word(status_word),
        .trace_valid(trace_valid), .trace_pc(trace_pc), .trace_instruction(trace_instruction),
        .trace_next_pc(trace_next_pc), .trace_rd_we(trace_rd_we), .trace_rd(trace_rd),
        .trace_wdata(trace_wdata), .trace_mem_req(trace_mem_req), .trace_mem_we(trace_mem_we),
        .trace_mem_addr(trace_mem_addr), .trace_mem_wdata(trace_mem_wdata),
        .trace_branch_taken(trace_branch_taken)
    );
    cpu_fault_tests u_fault_tests (.clk(clk), .done(fault_tests_done), .checks(fault_checks));

    task automatic check32(input string label, input [31:0] actual, input [31:0] expected);
        begin
            if (actual !== expected)
                $fatal(1, "Retire %0d %s: got=%08h expected=%08h", retired, label, actual, expected);
            checks = checks + 1;
        end
    endtask

    task automatic expect_retire(
        input [31:0] expected_pc, expected_instruction, expected_next_pc,
        input expected_rd_we, input [4:0] expected_rd, input [31:0] expected_wdata,
        input expected_mem_req, expected_mem_we,
        input [31:0] expected_mem_addr, expected_mem_wdata,
        input expected_branch_taken
    );
        begin
            @(posedge clk);
            #1;
            check32("fault", {31'd0, fault}, 32'd0);
            check32("trace_valid", {31'd0, trace_valid}, 32'd1);
            check32("PC", trace_pc, expected_pc);
            check32("instruction", trace_instruction, expected_instruction);
            check32("next PC", trace_next_pc, expected_next_pc);
            check32("actual PC", pc, expected_next_pc);
            check32("register write enable", {31'd0, trace_rd_we}, {31'd0, expected_rd_we});
            check32("destination register", {27'd0, trace_rd}, {27'd0, expected_rd});
            check32("writeback data", trace_wdata, expected_wdata);
            check32("memory request", {31'd0, trace_mem_req}, {31'd0, expected_mem_req});
            check32("memory write enable", {31'd0, trace_mem_we}, {31'd0, expected_mem_we});
            check32("memory address", trace_mem_addr, expected_mem_addr);
            check32("store data", trace_mem_wdata, expected_mem_wdata);
            check32("branch taken", {31'd0, trace_branch_taken}, {31'd0, expected_branch_taken});
            retired = retired + 1;
            $display("RETIRE %0d pc=%08h inst=%08h rd_we=%b rd=%0d data=%08h next=%08h",
                     retired, trace_pc, trace_instruction, trace_rd_we, trace_rd, trace_wdata, trace_next_pc);
        end
    endtask

    initial begin
        #100000;
        $fatal(1, "Single-cycle simulation timed out");
    end

    initial begin
        repeat (3) @(posedge clk);
        @(negedge clk);
        reset = 1'b0;
        // Generated, independently computed retirement expectations.
        `include "single_cycle_expected.vh"
        check32("7+5 stored at address 0", result_word, 32'd12);
        check32("1+2+3+4+5 stored at address 4", sum_word, 32'd15);
        check32("success signature at address 8", status_word, 32'd1);

        // The program ends with B finish, not a fictional HALT instruction.
        repeat (4) begin
            @(posedge clk);
            #1;
            check32("self loop PC", pc, trace_pc);
            check32("self loop register writes", {31'd0, trace_rd_we}, 32'd0);
            check32("self loop memory writes", {31'd0, trace_mem_we}, 32'd0);
            check32("self loop fault", {31'd0, fault}, 32'd0);
        end
        wait (fault_tests_done === 1'b1);
        $display("SINGLE CYCLE TESTS PASSED: %0d retired, 15 instruction kinds, %0d checks", retired, checks);
        $display("Memory: result=%0d sum=%0d status=%0d; fault checks=%0d",
                 result_word, sum_word, status_word, fault_checks);
        $finish;
    end
endmodule
