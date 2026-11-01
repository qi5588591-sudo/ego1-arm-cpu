`timescale 1ns / 1ps

// Artix-7 MMCM: 100MHz input * 6 / 1 / 60 = 10MHz CPU clock.
// The 600MHz VCO is within the Artix-7 MMCM operating range.
module ego1_clock (
    input  wire clk_100mhz,
    input  wire reset,
    output wire cpu_clk,
    output wire locked
);
    wire feedback_raw, feedback_buf, clock_raw;
    MMCME2_BASE #(
        .BANDWIDTH("OPTIMIZED"),
        .CLKIN1_PERIOD(10.000),
        .DIVCLK_DIVIDE(1),
        .CLKFBOUT_MULT_F(6.000),
        .CLKOUT0_DIVIDE_F(60.000),
        .CLKOUT0_DUTY_CYCLE(0.500),
        .CLKOUT0_PHASE(0.000),
        .STARTUP_WAIT("FALSE")
    ) u_mmcm (
        .CLKIN1(clk_100mhz), .CLKFBIN(feedback_buf),
        .CLKFBOUT(feedback_raw), .CLKOUT0(clock_raw),
        .LOCKED(locked), .PWRDWN(1'b0), .RST(reset)
    );
    BUFG u_feedback_buffer (.I(feedback_raw), .O(feedback_buf));
    BUFG u_cpu_clock_buffer (.I(clock_raw), .O(cpu_clk));
endmodule
