`timescale 1ns/1ps

module manual_start_fixture #(
    parameter integer HELD_AT_START = 1
)(output reg done = 0, output integer checks = 0);
    reg clk = 0;
    reg btn_reset = HELD_AT_START;
    wire led_heartbeat, led_pass, led_fault;
    integer cpu_edges = 0;
    integer heartbeat_edges = 0;
    integer before_edges;
    realtime last_rise = 0;
    always #5 clk = ~clk;

    ego1_arm_pipeline_top #(
        .HEARTBEAT_HALF_CYCLES(10), .MANUAL_ARM_CYCLES(100)
    ) dut (.*);

    always @(posedge dut.cpu_clk) begin
        cpu_edges++;
        if (last_rise != 0 && $realtime - last_rise != 1000)
            $fatal(1, "CPU period changed or clock glitched");
        last_rise = $realtime;
    end
    always @(led_heartbeat) heartbeat_edges++;

    task automatic require(input bit condition, input string message);
        if (!condition)
            $fatal(1, "case %0d: %s at %0t", HELD_AT_START, message, $time);
        checks++;
    endtask

    task automatic await_completion;
        wait (dut.cpu_reset === 0);
        #1;
        require(led_pass === 0, "No premature pass from retained RAM");
        repeat (400) @(posedge dut.cpu_clk);
        #1;
        require(led_pass === 1 && led_fault === 0, "CPU program passes");
        require(dut.result_word === 12 && dut.sum_word === 15 &&
                dut.status_word === 1, "Results are 12/15/1");
    endtask

    initial begin
        // Also exercise a press beginning before the arm delay expires.
        if (!HELD_AT_START) begin
            repeat (20) @(negedge clk);
            btn_reset = 1;
        end
        repeat (1000) @(negedge clk);
        require(dut.diag_ready === 1, "Arm delay expires");
        require(dut.diag_run_request === 0, "Held/early button cannot start CPU");
        require(cpu_edges == 0, "CPU clock has no edges before manual start");
        require(dut.cpu_reset === 1, "CPU stays reset with clock stopped");
        require(led_pass === 0 && led_fault === 0, "Initial indicators off");
        require(heartbeat_edges > 20, "Heartbeat works with CPU stopped");

        // A brief release followed by bounce back to pressed must not start.
        btn_reset = 0;
        repeat (20) @(negedge clk);
        require(dut.diag_release_seen === 0, "Short release is not accepted");
        btn_reset = 1;
        repeat (1000) @(negedge clk);
        require(cpu_edges == 0 && dut.diag_run_request === 0,
                "Release bounce cannot start CPU");

        btn_reset = 0;
        repeat (1000) @(negedge clk);
        require(cpu_edges == 0 && dut.diag_release_seen === 1,
                "Release arms start without starting CPU");
        btn_reset = 1;
        repeat (10) @(posedge dut.cpu_clk);
        #1;
        require(dut.diag_clock_enable === 1, "Fresh press starts CPU clock");
        require(dut.cpu_reset === 1, "Start press keeps CPU reset");
        require(led_pass === 0 && led_fault === 0, "Indicators stay off in reset");

        @(negedge clk); btn_reset = 0;
        await_completion();
        before_edges = cpu_edges;
        @(negedge clk); btn_reset = 1;
        repeat (10) @(posedge dut.cpu_clk);
        #1;
        require(dut.cpu_reset === 1 && led_pass === 0 && led_fault === 0,
                "Later button press resets CPU and clears indicators");
        require(cpu_edges > before_edges && dut.diag_clock_enable === 1,
                "Clock stays enabled after first start");
        @(negedge clk); btn_reset = 0;
        await_completion();
        done = 1;
    end
endmodule

module tb_ego1_arm_pipeline_manual_start;
    wire held_done, early_done;
    wire [31:0] held_checks, early_checks;
    manual_start_fixture #(.HELD_AT_START(1)) held(held_done, held_checks);
    manual_start_fixture #(.HELD_AT_START(0)) early(early_done, early_checks);
    initial begin
        #2000000;
        $fatal(1, "Manual start test timed out");
    end
    initial begin
        wait (held_done && early_done);
        $display("MANUAL START TESTS PASSED: %0d checks", held_checks + early_checks);
        $finish;
    end
endmodule
