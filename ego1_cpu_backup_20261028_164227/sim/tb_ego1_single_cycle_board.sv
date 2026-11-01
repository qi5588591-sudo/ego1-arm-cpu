`timescale 1ns / 1ps

module tb_ego1_single_cycle_board;
    reg clk_100mhz = 1'b0;
    reg btn_reset = 1'b0;
    wire led_pass, led_heartbeat, led_fault;
    integer checks = 0;
    integer transitions, i;
    reg old_heartbeat;
    realtime t1, t2;

    always #5 clk_100mhz = ~clk_100mhz;
    // Only the blink divider is shortened. The actual MMCM model and CPU run.
    ego1_single_cycle_board #(.HEARTBEAT_HALF_CYCLES(8)) dut (
        .clk_100mhz(clk_100mhz), .btn_reset(btn_reset),
        .led_pass(led_pass), .led_heartbeat(led_heartbeat), .led_fault(led_fault)
    );

    task automatic require(input bit condition, input string label);
        begin
            if (!condition)
                $fatal(1, "Board check failed: %s, time=%0t", label, $time);
            checks = checks + 1;
        end
    endtask

    task automatic await_program;
        begin
            wait (dut.clock_locked === 1'b1);
            wait (dut.cpu_reset === 1'b0);
            require(led_pass === 1'b0, "old RAM signature cannot pass after reset");
            repeat (80) @(posedge dut.cpu_clk);
            #1;
            require(led_pass === 1'b1, "CPU program turns on pass LED");
            require(led_fault === 1'b0, "normal program has no fault");
            require(dut.result_word === 32'd12, "7+5 result");
            require(dut.sum_word === 32'd15, "loop sum");
            require(dut.status_word === 32'd1, "success signature");
        end
    endtask

    initial begin
        #1000000;
        $fatal(1, "Board simulation timed out waiting for clock lock or completion");
    end

    initial begin
        await_program();
        @(posedge dut.cpu_clk); t1 = $realtime;
        @(posedge dut.cpu_clk); t2 = $realtime;
        require(((t2-t1) > 99.9) && ((t2-t1) < 100.1), "CPU clock is 10MHz");

        transitions = 0;
        old_heartbeat = led_heartbeat;
        for (i = 0; i < 32; i = i + 1) begin
            @(posedge dut.cpu_clk);
            #1;
            if (led_heartbeat != old_heartbeat)
                transitions = transitions + 1;
            old_heartbeat = led_heartbeat;
        end
        require(transitions == 4, "heartbeat divider toggles every eight test clocks");

        // A held button resets the clock manager and masks all LEDs.
        btn_reset = 1'b1;
        #2000;
        require(dut.clock_locked === 1'b0, "button resets MMCM");
        require(dut.cpu_reset === 1'b1, "reset remains asserted");
        require(led_pass === 1'b0, "pass LED off while reset held");
        require(led_heartbeat === 1'b0, "heartbeat off while reset held");
        require(led_fault === 1'b0, "fault LED off while reset held");
        btn_reset = 1'b0;
        await_program();

        // Exercise the indicator's fault path; core faults were checked earlier.
        force dut.cpu_fault = 1'b1;
        repeat (3) @(posedge dut.cpu_clk);
        #1;
        require(led_fault === 1'b1, "CPU fault lights fault LED");
        require(led_pass === 1'b0, "CPU fault clears pass LED");
        release dut.cpu_fault;
        repeat (3) @(posedge dut.cpu_clk);
        #1;
        require(led_fault === 1'b1, "fault indicator stays latched");

        btn_reset = 1'b1;
        #2000;
        btn_reset = 1'b0;
        await_program();
        $display("BOARD TESTS PASSED: %0d checks; actual MMCM model; CPU 10MHz", checks);
        $finish;
    end
endmodule
