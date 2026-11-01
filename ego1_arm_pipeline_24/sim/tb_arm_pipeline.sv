`timescale 1ns/1ps
module tb_arm_pipeline;
    reg clk=0;
    always #5 clk=~clk;
    wire [8:0] done;
    wire [45:0] fault_done;
    wire [5:0] mdu_done;
    wire unit_done,reset_done;
    wire [31:0] checks[0:8],fault_checks[0:45],cycles[0:8];
    wire [31:0] mdu_checks[0:5],mdu_cycles[0:5],unit_checks,reset_checks;
    integer total,i;
    generate for(genvar image=0;image<3;image++)begin:g_image
        for(genvar core=0;core<3;core++)begin:g_core
            pipeline_program_test #(.IMAGE(image),.CORE(core)) test(.clk(clk),
                .done(done[image*3+core]),.checks(checks[image*3+core]),.completed_cycles(cycles[image*3+core]));
        end
    end
    for(genvar n=0;n<46;n++)begin:g_fault
        pipeline_fault_test #(.CORE(n<23?1:2),.CASE_ID(n%23)) test(.clk(clk),
            .done(fault_done[n]),.checks(fault_checks[n]));
    end
    for(genvar n=0;n<6;n++)begin:g_mdu
        pipeline_program_test #(.IMAGE(4+n/2),.CORE(1+n%2)) test(.clk(clk),
            .done(mdu_done[n]),.checks(mdu_checks[n]),.completed_cycles(mdu_cycles[n]));
    end endgenerate
    mdu_unit_test unit_test(.clk(clk),.done(unit_done),.checks(unit_checks));
    mdu_reset_test reset_test(.clk(clk),.done(reset_done),.checks(reset_checks));
    initial begin #2000000;$fatal(1,"Pipeline simulation timeout");end
    initial begin
        wait((&done)&&(&fault_done)&&(&mdu_done)&&unit_done&&reset_done);total=0;
        for(i=0;i<9;i++)total+=checks[i];
        for(i=0;i<46;i++)total+=fault_checks[i];
        for(i=0;i<6;i++)total+=mdu_checks[i];
        total+=unit_checks+reset_checks;
        for(i=0;i<3;i++)begin
            if(cycles[i*3+1]>=cycles[i*3+2])$fatal(1,"Forwarding did not improve image %0d",i);
            $display("PERFORMANCE image=%0d single=%0d forwarding=%0d stall_only=%0d saved=%0d",i,cycles[i*3],cycles[i*3+1],cycles[i*3+2],cycles[i*3+2]-cycles[i*3+1]);
        end
        for(i=0;i<3;i++)begin
            if(mdu_cycles[i*2]>=mdu_cycles[i*2+1])$fatal(1,"MDU forwarding did not improve image %0d",i);
            $display("MDU PERFORMANCE image=%0d forwarding=%0d stall_only=%0d",i+4,mdu_cycles[i*2],mdu_cycles[i*2+1]);
        end
        $display("ARM PIPELINE TESTS PASSED: %0d checks; 15 program/core cases; 46 precise-fault cases; MDU unit and reset",total);
        $finish;
    end
endmodule
