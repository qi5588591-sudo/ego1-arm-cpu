`timescale 1ns / 1ps

module ego1_arm_top #(
    parameter integer HEARTBEAT_HALF_CYCLES = 50000000
) (
    input wire clk,
    input wire btn_reset,
    output wire led_heartbeat,
    output reg led_pass = 1'b0,
    output reg led_fault = 1'b0
);
    // Same independent 100MHz heartbeat as the verified LED-only project.
    reg [25:0] heartbeat_count = 26'd0;
    reg heartbeat = 1'b0;
    assign led_heartbeat = heartbeat;
    always @(posedge clk) begin
        if (heartbeat_count == HEARTBEAT_HALF_CYCLES - 1) begin
            heartbeat_count <= 26'd0;
            heartbeat <= ~heartbeat;
        end else
            heartbeat_count <= heartbeat_count + 26'd1;
    end

    // 100MHz / 100 = 1MHz, routed on a dedicated global clock buffer.
    // The XDC explicitly declares this generated clock; no MMCM is required.
    reg [5:0] divide_count = 6'd0;
    reg cpu_clock_div = 1'b0;
    wire cpu_clk;
    always @(posedge clk) begin
        if (divide_count == 6'd49) begin
            divide_count <= 6'd0;
            cpu_clock_div <= ~cpu_clock_div;
        end else
            divide_count <= divide_count + 6'd1;
    end
    BUFG u_cpu_clock (.I(cpu_clock_div), .O(cpu_clk));

    reg [7:0] startup_count = 8'd0;
    (* ASYNC_REG = "TRUE" *) reg [1:0] button_sync = 2'b00;
    reg reset_request = 1'b1;
    always @(posedge clk) begin
        if (startup_count != 8'hff)
            startup_count <= startup_count + 8'd1;
        button_sync <= {button_sync[0], btn_reset};
        reset_request <= (startup_count != 8'hff) || button_sync[1];
    end
    // Both clocks keep running. Transfer a registered reset through two CPU
    // stages; assertion and release are synchronous and all paths are timed.
    (* ASYNC_REG = "TRUE" *) reg [1:0] reset_pipe = 2'b11;
    always @(posedge cpu_clk)
        reset_pipe <= {reset_pipe[0], reset_request};
    wire cpu_reset = reset_pipe[1];
    wire cpu_fault, trace_valid, trace_mem_we;
    wire [31:0] result_word, sum_word, status_word;
    wire [31:0] trace_mem_addr, trace_mem_wdata;

    arm_soc u_soc (
        .clk(cpu_clk), .reset(cpu_reset), .fault(cpu_fault),
        .result_word(result_word), .sum_word(sum_word), .status_word(status_word),
        .trace_valid(trace_valid), .trace_mem_we(trace_mem_we),
        .trace_mem_addr(trace_mem_addr), .trace_mem_wdata(trace_mem_wdata)
    );

    always @(posedge cpu_clk) begin
        if (cpu_reset) begin
            led_pass <= 1'b0;
            led_fault <= 1'b0;
        end else if (cpu_fault) begin
            led_pass <= 1'b0;
            led_fault <= 1'b1;
        end else if (!led_fault && trace_valid && trace_mem_we &&
                     trace_mem_addr == 32'h00001008) begin
            // Require a fresh completion write, even if RAM retains old data.
            if (trace_mem_wdata == 32'd1 && status_word == 32'd1 &&
                result_word == 32'd12 && sum_word == 32'd15)
                led_pass <= 1'b1;
            else begin
                led_pass <= 1'b0;
                led_fault <= 1'b1;
            end
        end
    end
endmodule

