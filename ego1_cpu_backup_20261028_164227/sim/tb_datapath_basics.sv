`timescale 1ns / 1ps

module tb_datapath_basics;
    reg clk = 1'b0;
    reg reset = 1'b1;
    reg we = 1'b0;
    reg [4:0] waddr = 5'd0;
    reg [31:0] wdata = 32'd0;
    reg [4:0] raddr1 = 5'd0;
    reg [4:0] raddr2 = 5'd0;
    reg [3:0] alu_op = 4'd0;
    wire [31:0] rdata1, rdata2, alu_result;
    wire zero;
    integer checks = 0;
    integer alu_vectors = 0;
    integer i;

    always #5 clk = ~clk;

    datapath_basics dut (
        .clk(clk), .reset(reset), .we(we),
        .waddr(waddr), .wdata(wdata),
        .raddr1(raddr1), .raddr2(raddr2), .alu_op(alu_op),
        .rdata1(rdata1), .rdata2(rdata2),
        .alu_result(alu_result), .zero(zero)
    );

    task automatic check32(input string label,
                           input [31:0] actual, input [31:0] expected);
        begin
            if (actual !== expected) begin
                $display("FAIL %s: got=%08h expected=%08h time=%0t",
                         label, actual, expected, $time);
                $fatal(1, "Datapath check failed");
            end
            checks = checks + 1;
        end
    endtask

    task automatic write_register(input [4:0] addr, input [31:0] data);
        begin
            @(negedge clk);
            we = 1'b1;
            waddr = addr;
            wdata = data;
            @(posedge clk);
            #1;
            we = 1'b0;
        end
    endtask

    task automatic check_alu(input string label, input [3:0] op,
                             input [31:0] a, input [31:0] b,
                             input [31:0] expected);
        begin
            write_register(5'd1, a);
            write_register(5'd2, b);
            raddr1 = 5'd1;
            raddr2 = 5'd2;
            alu_op = op;
            #1;
            check32(label, alu_result, expected);
            check32({label, " zero"}, {31'd0, zero},
                    (expected == 32'd0) ? 32'd1 : 32'd0);
            alu_vectors = alu_vectors + 1;
        end
    endtask

    initial begin
        // Watchdog: a broken clock or stuck test cannot silently pass.
        #100000;
        $fatal(1, "Simulation timed out");
    end

    initial begin
        // Reset is a design choice; LA32 only requires r0 to stay zero.
        repeat (2) @(posedge clk);
        #1;
        reset = 1'b0;
        for (i = 0; i < 32; i = i + 1) begin
            raddr1 = i;
            raddr2 = 31 - i;
            #1;
            check32("reset port1", rdata1, 32'd0);
            check32("reset port2", rdata2, 32'd0);
        end

        // Exercise both ports and every writable register, including r31.
        for (i = 1; i < 32; i = i + 1)
            write_register(i, 32'hA5000000 + i);
        for (i = 1; i < 32; i = i + 1) begin
            raddr1 = i;
            raddr2 = 32 - i;
            #1;
            check32("register port1", rdata1, 32'hA5000000 + i);
            check32("register port2", rdata2, 32'hA5000000 + 32 - i);
        end

        write_register(5'd0, 32'hFFFFFFFF);
        raddr1 = 5'd0;
        raddr2 = 5'd0;
        #1;
        check32("r0 ignores write port1", rdata1, 32'd0);
        check32("r0 ignores write port2", rdata2, 32'd0);

        // With write enable low, crossing a clock edge must preserve data.
        @(negedge clk);
        we = 1'b0;
        waddr = 5'd7;
        wdata = 32'hDEADBEEF;
        raddr1 = 5'd7;
        raddr2 = 5'd7;
        @(posedge clk);
        #1;
        check32("disabled write port1", rdata1, 32'hA5000007);
        check32("disabled write port2", rdata2, 32'hA5000007);

        // Same-address reads change only after the rising write edge.
        @(negedge clk);
        we = 1'b1;
        waddr = 5'd7;
        wdata = 32'h13579BDF;
        #1;
        check32("no early write port1", rdata1, 32'hA5000007);
        check32("no early write port2", rdata2, 32'hA5000007);
        @(posedge clk);
        #1;
        we = 1'b0;
        check32("edge write port1", rdata1, 32'h13579BDF);
        check32("edge write port2", rdata2, 32'h13579BDF);

        // Fixed, independently specified arithmetic and bit-pattern examples.
        check_alu("ADD 7+5",       0, 32'd7,        32'd5,        32'd12);
        check_alu("ADD wrap",      0, 32'hFFFFFFFF, 32'd1,        32'd0);
        check_alu("ADD sign edge", 0, 32'h7FFFFFFF, 32'd1,        32'h80000000);
        check_alu("ADD negative",  0, 32'hFFFFFFF9, 32'd5,        32'hFFFFFFFE);
        check_alu("SUB positive",  1, 32'd7,        32'd5,        32'd2);
        check_alu("SUB negative",  1, 32'd5,        32'd7,        32'hFFFFFFFE);
        check_alu("SUB zero",      1, 32'h80000000, 32'h80000000, 32'd0);
        check_alu("SUB wrap",      1, 32'h80000000, 32'd1,        32'h7FFFFFFF);
        check_alu("AND pattern",   2, 32'hF0F0AA55, 32'h0FF055AA, 32'h00F00000);
        check_alu("AND zero",      2, 32'hAAAAAAAA, 32'h55555555, 32'd0);
        check_alu("OR pattern",    3, 32'hF0F0AA55, 32'h0FF055AA, 32'hFFF0FFFF);
        check_alu("OR zero",       3, 32'd0,        32'd0,        32'd0);
        check_alu("XOR pattern",   4, 32'hF0F0AA55, 32'h0FF055AA, 32'hFF00FFFF);
        check_alu("XOR zero",      4, 32'h12345678, 32'h12345678, 32'd0);
        check_alu("NOR pattern",   5, 32'hF0F0AA55, 32'h0FF055AA, 32'h000F0000);
        check_alu("NOR ones",      5, 32'd0,        32'd0,        32'hFFFFFFFF);
        check_alu("NOR zero",      5, 32'hFFFFFFFF, 32'd0,        32'd0);
        check_alu("SLL 0",         6, 32'h12345678, 32'd0,        32'h12345678);
        check_alu("SLL 1",         6, 32'h80000001, 32'd1,        32'd2);
        check_alu("SLL 31",        6, 32'd1,        32'd31,       32'h80000000);
        check_alu("SLL 32 masks",  6, 32'h12345678, 32'd32,       32'h12345678);
        check_alu("SRL 1",         7, 32'h80000000, 32'd1,        32'h40000000);
        check_alu("SRL 31",        7, 32'hFFFFFFFF, 32'd31,       32'd1);
        check_alu("SRL 63 masks",  7, 32'h80000000, 32'd63,       32'd1);
        check_alu("SRA negative",  8, 32'h80000000, 32'd1,        32'hC0000000);
        check_alu("SRA minus one", 8, 32'hFFFFFFFF, 32'd31,       32'hFFFFFFFF);
        check_alu("SRA positive",  8, 32'h7FFFFFFF, 32'd1,        32'h3FFFFFFF);
        check_alu("SRA 32 masks",  8, 32'h80000000, 32'd32,       32'h80000000);
        check_alu("SLT sign",      9, 32'hFFFFFFFF, 32'd1,        32'd1);
        check_alu("SLT min max",   9, 32'h80000000, 32'h7FFFFFFF, 32'd1);
        check_alu("SLT max min",   9, 32'h7FFFFFFF, 32'h80000000, 32'd0);
        check_alu("SLT equal",     9, 32'hFFFFFFFF, 32'hFFFFFFFF, 32'd0);
        check_alu("SLTU sign",     10,32'hFFFFFFFF, 32'd1,        32'd0);
        check_alu("SLTU min max",  10,32'h80000000, 32'h7FFFFFFF, 32'd0);
        check_alu("SLTU max min",  10,32'h7FFFFFFF, 32'h80000000, 32'd1);
        check_alu("SLTU equal",    10,32'd1,        32'd1,        32'd0);
        check_alu("PASS B upper",  11,32'hFFFFFFFF, 32'h12345000, 32'h12345000);
        check_alu("PASS B zero",   11,32'hFFFFFFFF, 32'd0,        32'd0);
        check_alu("unused op",     15,32'hFFFFFFFF, 32'hFFFFFFFF, 32'd0);

        // A miniature datapath transaction: r1=7, r2=5, r3=r1+r2.
        write_register(5'd1, 32'd7);
        write_register(5'd2, 32'd5);
        raddr1 = 5'd1;
        raddr2 = 5'd2;
        alu_op = 4'd0;
        #1;
        write_register(5'd3, alu_result);
        raddr1 = 5'd3;
        #1;
        check32("integrated result r3", rdata1, 32'd12);

        // Reset must override an attempted write and clear every register.
        @(negedge clk);
        reset = 1'b1;
        we = 1'b1;
        waddr = 5'd31;
        wdata = 32'hCAFEBABE;
        @(posedge clk);
        #1;
        reset = 1'b0;
        we = 1'b0;
        for (i = 0; i < 32; i = i + 1) begin
            raddr1 = i;
            raddr2 = 31 - i;
            #1;
            check32("second reset port1", rdata1, 32'd0);
            check32("second reset port2", rdata2, 32'd0);
        end

        $display("ALL TESTS PASSED: %0d checks, %0d ALU vectors", checks, alu_vectors);
        $finish;
    end
endmodule
