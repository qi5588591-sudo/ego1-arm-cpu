`timescale 1ns/1ps
module mdu_reset_test(input wire clk,output reg done=0,output integer checks=0);
    reg reset=1;
    wire fault,trace_valid,actual_store;
    wire [31:0] status_word,result_word,sum_word;
    pipeline_fixture #(.IMAGE(4),.CORE(1)) dut(.clk(clk),.reset(reset),.fault(fault),
        .trace_valid(trace_valid),.actual_store(actual_store),.status_word(status_word),
        .result_word(result_word),.sum_word(sum_word));
    task automatic require(input bit condition,input string message);
        if(!condition)$fatal(1,"MDU pipeline reset: %s",message);
        checks++;
    endtask
    integer k,cycles;
    initial begin
        repeat(3)@(posedge clk);@(negedge clk);reset=0;
        for(k=0;k<3;k++)begin
            // Cancel one MUL, one SDIV and one UDIV in the full pipeline.
            wait(dut.g_pipeline.cpu.u_mdu.busy===1 &&
                 dut.g_pipeline.cpu.u_mdu.operation==k);
            repeat(k==0?1:k==1?16:31)@(posedge clk);
            @(negedge clk);reset=1;
            repeat(3)begin
                @(posedge clk);#1;
                require(!dut.g_pipeline.cpu.u_mdu.busy&&!dut.g_pipeline.cpu.u_mdu.done,
                        "Reset kills MDU completion");
                require(!trace_valid&&!actual_store,"No retirement or store during reset");
            end
            @(negedge clk);reset=0;
        end
        cycles=0;
        while(status_word!==1)begin
            @(posedge clk);#1;cycles++;
            if(fault||cycles>3000)$fatal(1,"MDU reset recovery failed");
        end
        require(result_word===12&&sum_word===15,"Fresh program completes after cancellation");
        $display("MDU PIPELINE RESET PASSED: %0d checks",checks);
        done=1;
    end
endmodule
