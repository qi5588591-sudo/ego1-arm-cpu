`timescale 1ns/1ps
module tb_arm_cpu;
    reg clk=0;
    always #5 clk=~clk;
    wire demo_done,stress_done,condition_done;
    wire [9:0] fault_done;
    wire [31:0] demo_checks,stress_checks,condition_checks;
    wire [31:0] fault_checks[0:9];
    integer total,i;
    arm_program_test #(.STRESS(0)) demo(.clk(clk),.done(demo_done),.checks(demo_checks));
    arm_program_test #(.STRESS(1)) stress(.clk(clk),.done(stress_done),.checks(stress_checks));
    arm_condition_test conditions(.done(condition_done),.checks(condition_checks));
    generate for(genvar k=0;k<10;k++) begin:g_fault
        arm_fault_probe #(.CASE_ID(k)) probe(.clk(clk),.done(fault_done[k]),.checks(fault_checks[k]));
    end endgenerate
    initial begin
        #100000;
        $fatal(1,"ARM verification timeout");
    end
    initial begin
        wait(demo_done && stress_done && condition_done && (&fault_done));
        total=demo_checks+stress_checks+condition_checks;
        for(i=0;i<10;i++) total+=fault_checks[i];
        $display("ARM CPU TESTS PASSED: total=%0d checks; 21 instruction kinds; 10 fault cases; 256 condition cases",total);
        $finish;
    end
endmodule
