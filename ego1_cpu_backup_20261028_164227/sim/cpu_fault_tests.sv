`timescale 1ns / 1ps

// Runs in parallel with the normal program, using a separate CPU instance.
// The laboratory environment reports invalid memory/fetch accesses as faults.
module cpu_fault_tests (
    input wire clk,
    output reg done = 1'b0,
    output integer checks = 0
);
    reg reset = 1'b1;
    integer test_case = 0;
    reg [31:0] instruction;
    wire [31:0] pc, next_pc, data_addr, data_wdata;
    wire fault, data_req, data_we, trace_valid, trace_rd_we, trace_mem_we;
    wire instruction_valid = (pc == 32'd0) && (test_case != 6);
    wire data_fault = data_req && ((data_addr[1:0] != 2'd0) || (data_addr[31:8] != 24'd0));
    integer c, elapsed;
    reg [31:0] expected_pc;

    // always_comb also evaluates once at time zero, before any case changes.
    always_comb begin
        case (test_case)
            0: instruction = 32'hffffffff; // Unsupported instruction.
            1: instruction = 32'h02c01c01; // ADDI.D, outside this LA32 subset.
            2: instruction = 32'h28800801; // LD.W r1,r0,2: unaligned.
            3: instruction = 32'h29800801; // ST.W r1,r0,2: unaligned.
            4: instruction = 32'h28840001; // LD.W r1,r0,256: out of RAM.
            5: instruction = 32'h29840001; // ST.W r1,r0,256: out of RAM.
            6: instruction = 32'h02801c01; // Valid ADDI.W but invalid fetch.
            7: instruction = 32'h50040000; // B +1024, then invalid fetch.
            8: instruction = 32'h50000001; // B +262144: upper split offset bits.
            9: instruction = 32'h53ffffff; // B -4: sign-extended split offset.
            default: instruction = 32'hffffffff;
        endcase
    end

    single_cycle_cpu dut (
        .clk(clk), .reset(reset), .instruction(instruction),
        .instruction_valid(instruction_valid), .data_rdata(32'd0), .data_fault(data_fault),
        .pc(pc), .next_pc(next_pc), .fault(fault), .data_req(data_req), .data_we(data_we),
        .data_addr(data_addr), .data_wdata(data_wdata),
        .trace_valid(trace_valid), .trace_rd_we(trace_rd_we), .trace_mem_we(trace_mem_we)
    );

    task automatic require(input bit condition, input string label);
        begin
            if (!condition)
                $fatal(1, "Fault test %0d failed: %s", test_case, label);
            checks = checks + 1;
        end
    endtask

    initial begin
        for (c = 0; c < 10; c = c + 1) begin
            @(negedge clk);
            reset = 1'b1;
            test_case = c;
            repeat (2) @(posedge clk);
            #1;
            require(fault === 1'b0, "reset clears fault");
            require(pc === 32'd0, "reset clears PC");
            require(trace_valid === 1'b0, "no retire during reset");
            @(negedge clk);
            reset = 1'b0;
            elapsed = 0;
            while ((fault !== 1'b1) && (elapsed < 4)) begin
                @(posedge clk);
                #1;
                require(trace_rd_we === 1'b0, "no register side effect");
                require(trace_mem_we === 1'b0, "no memory side effect");
                elapsed = elapsed + 1;
            end
            require(fault === 1'b1, "fault detected");
            expected_pc = (c == 7) ? 32'd1024 :
                          (c == 8) ? 32'h00040000 :
                          (c == 9) ? 32'hfffffffc : 32'd0;
            require(pc === expected_pc, "faulting PC preserved");
            repeat (3) begin
                @(posedge clk);
                #1;
                require(fault === 1'b1, "fault remains latched");
                require(pc === expected_pc, "PC stays frozen");
                require(trace_valid === 1'b0, "no retire after fault");
                require(data_we === 1'b0, "no store after fault");
                require(data_req === 1'b0, "no request after fault");
            end
        end
        done = 1'b1;
        $display("FAULT TESTS PASSED: 10 cases, %0d checks", checks);
    end
endmodule
