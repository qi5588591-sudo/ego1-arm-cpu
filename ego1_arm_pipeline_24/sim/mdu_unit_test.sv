`timescale 1ns/1ps
module mdu_unit_test(input wire clk,output reg done=0,output integer checks=0);
    reg reset=1,start=0;
    reg [1:0] op=0;
    reg [31:0] a=0,b=0;
    wire busy,result_done;
    wire [31:0] result;
    arm_mdu dut(.clk(clk),.reset(reset),.start(start),.op(op),.a(a),.b(b),
        .busy(busy),.done(result_done),.result(result));
    task automatic require(input bit condition,input string message);
        if(!condition)$fatal(1,"MDU unit: %s at %0t",message,$time);
        checks++;
    endtask
    task automatic check_mdu(input [1:0] operation,input [31:0] lhs,rhs,expected);
        integer cycles;
        @(negedge clk);op=operation;a=lhs;b=rhs;start=1;
        @(posedge clk);#1;
        require(busy===1&&result_done===0,"Request accepted");
        @(negedge clk);start=0;a=32'hdeadbeef;b=32'hcafebabe;op=3;
        cycles=0;
        do begin
            @(posedge clk);#1;cycles++;
            if(cycles>32)$fatal(1,"MDU unit timeout");
            if(!result_done)begin
                @(negedge clk);a=a+1;b=b-1;start=(cycles==5);
            end
        end while(!result_done);
        require(cycles==32,"Exactly 32 iterations");
        if(result!==expected)$fatal(1,"MDU op=%0d a=%h b=%h got=%h expected=%h",operation,lhs,rhs,result,expected);
        checks++;
        require(!busy,"Completion releases busy");
        @(negedge clk);start=0;
        @(posedge clk);#1;
        require(!result_done&&!busy&&result===expected,"One-cycle done; result held while idle");
    endtask
    integer abort_delay;
    initial begin
        repeat(3)@(posedge clk);@(negedge clk);reset=0;
        `include "mdu_unit_expected.vh"
        for(abort_delay=0;abort_delay<32;abort_delay++)begin
            @(negedge clk);op=1;a=32'h80000000;b=3;start=1;
            @(posedge clk);#1;
            @(negedge clk);start=0;
            repeat(abort_delay)@(negedge clk);
            reset=1;@(posedge clk);#1;
            require(!busy&&!result_done,"Reset cancels in-flight request");
            @(negedge clk);reset=0;
            check_mdu(0,7,9,63);
        end
        $display("MDU UNIT PASSED: %0d checks; 1443 vectors; all 32 reset positions",checks);
        done=1;
    end
endmodule
