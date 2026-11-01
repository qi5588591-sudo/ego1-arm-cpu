`timescale 1ns / 1ps

module ego1_single_cycle_board #(
    parameter integer HEARTBEAT_HALF_CYCLES = 5000000
) (
    input  wire clk_100mhz,
    input  wire btn_reset,
    output wire led_pass,
    output wire led_heartbeat,
    output wire led_fault
);
    wire cpu_clk, clock_locked;
    // Assert reset asynchronously on loss of lock; release it on CPU edges.
    (* ASYNC_REG = "TRUE" *) reg [1:0] reset_pipe = 2'b11;
    wire cpu_reset = reset_pipe[1];
    reg test_pass;
    reg test_fault;
    reg heartbeat;
    reg [22:0] heartbeat_counter;
    wire cpu_fault, trace_valid, trace_mem_we;
    wire [31:0] result_word, sum_word, status_word;
    wire [31:0] trace_mem_addr, trace_mem_wdata;

    ego1_clock u_clock (
        .clk_100mhz(clk_100mhz), .reset(btn_reset),
        .cpu_clk(cpu_clk), .locked(clock_locked)
    );
    always @(posedge cpu_clk or negedge clock_locked) begin
        if (!clock_locked)
            reset_pipe <= 2'b11;
        else
            reset_pipe <= {reset_pipe[0], 1'b0};
    end

    single_cycle_soc u_soc (
        .clk(cpu_clk), .reset(cpu_reset), .fault(cpu_fault),
        .result_word(result_word), .sum_word(sum_word), .status_word(status_word),
        .trace_valid(trace_valid), .trace_mem_we(trace_mem_we),
        .trace_mem_addr(trace_mem_addr), .trace_mem_wdata(trace_mem_wdata)
    );

    // Mask indicators while the MMCM is resetting, even if its clock stops.
    assign led_pass = test_pass && !cpu_reset && clock_locked;
    assign led_heartbeat = heartbeat && !cpu_reset && clock_locked;
    assign led_fault = test_fault && !cpu_reset && clock_locked;

    always @(posedge cpu_clk) begin
        if (cpu_reset) begin
            test_pass <= 1'b0;
            test_fault <= 1'b0;
            heartbeat <= 1'b0;
            heartbeat_counter <= 23'd0;
        end else begin
            if (heartbeat_counter == HEARTBEAT_HALF_CYCLES - 1) begin
                heartbeat_counter <= 23'd0;
                heartbeat <= ~heartbeat;
            end else begin
                heartbeat_counter <= heartbeat_counter + 23'd1;
            end

            if (cpu_fault) begin
                test_pass <= 1'b0;
                test_fault <= 1'b1;
            end else if (!test_fault && trace_valid && trace_mem_we &&
                         (trace_mem_addr == 32'd8)) begin
                // Require a NEW completion write after every reset. RAM retains
                // its old signature across CPU reset, which alone cannot pass.
                if ((trace_mem_wdata == 32'd1) && (status_word == 32'd1) &&
                    (result_word == 32'd12) && (sum_word == 32'd15)) begin
                    test_pass <= 1'b1;
                end else begin
                    test_pass <= 1'b0;
                    test_fault <= 1'b1;
                end
            end
        end
    end
endmodule
