`timescale 1ns/1ps
module tb_arm_pipeline;
    reg clk=0;
    always #5 clk=~clk;
    wire [8:0] done;
    wire [19:0] fault_done;
    wire [31:0] checks[0:8],fault_checks[0:19],cycles[0:8];
    integer total,i;
    generate for(genvar image=0;image<3;image++)begin:g_image
        for(genvar core=0;core<3;core++)begin:g_core
            pipeline_program_test #(.IMAGE(image),.CORE(core)) test(.clk(clk),
                .done(done[image*3+core]),.checks(checks[image*3+core]),.completed_cycles(cycles[image*3+core]));
        end
    end
    for(genvar n=0;n<20;n++)begin:g_fault
        pipeline_fault_test #(.CORE(n<10?1:2),.CASE_ID(n%10)) test(.clk(clk),
            .done(fault_done[n]),.checks(fault_checks[n]));
    end endgenerate
    initial begin #1000000;$fatal(1,"Pipeline simulation timeout");end
    initial begin
        wait((&done)&&(&fault_done));total=0;
        for(i=0;i<9;i++)total+=checks[i];
        for(i=0;i<20;i++)total+=fault_checks[i];
        for(i=0;i<3;i++)begin
            if(cycles[i*3+1]>=cycles[i*3+2])$fatal(1,"Forwarding did not improve image %0d",i);
            $display("PERFORMANCE image=%0d single=%0d forwarding=%0d stall_only=%0d saved=%0d",i,cycles[i*3],cycles[i*3+1],cycles[i*3+2],cycles[i*3+2]-cycles[i*3+1]);
        end
        $display("ARM PIPELINE TESTS PASSED: %0d checks; 3 images x 3 cores; 20 precise-fault cases",total);
        $finish;
    end
endmodule
