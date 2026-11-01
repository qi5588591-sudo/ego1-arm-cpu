`timescale 1ns / 1ps
module tb_ego1_arm_top;
    reg clk = 0;
    reg btn_reset = 0;
    wire led_heartbeat, led_pass, led_fault;
    integer checks = 0;
    integer transitions, n;
    reg previous_heartbeat;
    realtime t1, t2;
    always #5 clk = ~clk;
    // Keep the real /100 CPU divider. Only the visible blink is accelerated.
    ego1_arm_top #(.HEARTBEAT_HALF_CYCLES(10)) dut (.*);
    task automatic require(input bit condition, input string message);
        if (!condition) $fatal(1, "%s at %0t", message, $time);
        else checks++;
    endtask
    task automatic await_completion;
        wait (dut.cpu_reset === 0);
        #1;
        require(led_pass === 0, "Retained RAM cannot cause premature pass");
        repeat (220) @(posedge dut.cpu_clk);
        #1;
        require(led_pass === 1, "Program completion");
        require(led_fault === 0, "No normal fault");
        require(dut.result_word === 12, "7+5=12");
        require(dut.sum_word === 15, "Sum 1..5=15");
        require(dut.status_word === 1, "Completion signature=1");
    endtask
    task automatic check_heartbeat;
        transitions = 0;
        previous_heartbeat = led_heartbeat;
        repeat (40) begin
            @(posedge clk); #1;
            if (led_heartbeat != previous_heartbeat) transitions++;
            previous_heartbeat = led_heartbeat;
        end
        require(transitions == 4, "Heartbeat independent of CPU reset/fault");
    endtask
    initial begin
        #2000000;
        $fatal(1, "Board test timeout");
    end
    initial begin
        await_completion();
        @(posedge dut.cpu_clk); t1=$realtime;
        @(posedge dut.cpu_clk); t2=$realtime;
        require(t2-t1 == 1000, "CPU clock period=1000ns");
        check_heartbeat();
        @(negedge clk); btn_reset = 1;
        repeat (6) @(posedge dut.cpu_clk); #1;
        require(dut.cpu_reset === 1, "Button holds CPU reset");
        require(led_pass === 0 && led_fault === 0, "Reset clears CPU indicators");
        check_heartbeat();
        @(negedge clk); btn_reset = 0;
        await_completion();
        force dut.cpu_fault = 1;
        repeat (3) @(posedge dut.cpu_clk); #1;
        require(led_fault === 1 && led_pass === 0, "Fault indication");
        release dut.cpu_fault;
        repeat (3) @(posedge dut.cpu_clk); #1;
        require(led_fault === 1, "Fault indication sticky");
        check_heartbeat();
        @(negedge clk); btn_reset = 1;
        repeat (6) @(posedge dut.cpu_clk);
        @(negedge clk); btn_reset = 0;
        await_completion();
        $display("BOARD TESTS PASSED: %0d checks; CPU clock=1MHz; heartbeat independent", checks);
        $finish;
    end
endmodule

