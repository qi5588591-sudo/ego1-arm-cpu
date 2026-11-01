module led_blink (
    input  wire clk,
    output reg  led
);

    reg [25:0] counter;

    // Vivado FPGA配置完成后的初始状态
    initial begin
        counter = 26'd0;
        led     = 1'b0;
    end

    // EGO1输入时钟为100MHz
    // 每计数5000万次，即0.5秒，翻转一次LED
    always @(posedge clk) begin
        if (counter == 26'd49_999_999) begin
            counter <= 26'd0;
            led     <= ~led;
        end else begin
            counter <= counter + 26'd1;
        end
    end

endmodule