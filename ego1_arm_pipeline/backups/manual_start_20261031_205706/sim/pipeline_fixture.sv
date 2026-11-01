`timescale 1ns/1ps
// CORE: 0=known single-cycle baseline, 1=forwarding pipeline, 2=stall-only pipeline.
module pipeline_fixture #(parameter IMAGE=0,CORE=1,CASE_ID=0)(input wire clk,reset,
    output wire fault,trace_valid,trace_executed,trace_rd_we,trace_mem_req,trace_mem_we,trace_byte,
    output wire [31:0] trace_pc,trace_instruction,trace_next_pc,trace_wdata,trace_mem_addr,trace_mem_wdata,
    output wire [3:0] trace_rd,trace_nzcv,
    output wire [31:0] result_word,sum_word,status_word,fault_pc,expected_fault_pc,
    output wire [31:0] cycle_count,retired_count,stall_count,load_stall_count,
    output wire [31:0] flag_stall_count,flush_count,forward_count,flag_forward_count,
    output wire [31:0] debug_r0,debug_r1,debug_r3,output wire [3:0] nzcv,
    output wire actual_store);
    wire [31:0] pc,instruction,data_rdata,data_addr,data_wdata;
    wire instruction_valid,data_address_valid,data_req,data_we,data_byte;
    assign actual_store=data_we;
    generate if(IMAGE==0)begin:g_demo
        arm_demo_rom rom(.address(pc),.instruction(instruction),.valid(instruction_valid));
        assign expected_fault_pc=0;
    end else if(IMAGE==1)begin:g_stress
        arm_stress_rom rom(.address(pc),.instruction(instruction),.valid(instruction_valid));
        assign expected_fault_pc=0;
    end else if(IMAGE==2)begin:g_hazards
        arm_hazards_rom rom(.address(pc),.instruction(instruction),.valid(instruction_valid));
        assign expected_fault_pc=0;
    end else begin:g_fault
        arm_fault_rom #(.CASE_ID(CASE_ID)) rom(.address(pc),.instruction(instruction),
            .valid(instruction_valid),.fault_address(expected_fault_pc));
    end endgenerate
    arm_data_ram ram(.clk(clk),.reset(reset),.we(data_we),.byte_access(data_byte),
        .address(data_addr),.wdata(data_wdata),.rdata(data_rdata),.address_valid(data_address_valid),
        .result_word(result_word),.sum_word(sum_word),.status_word(status_word));
    generate if(CORE==0)begin:g_single
        arm_single_cycle_cpu cpu(.*);
        assign cycle_count=0,retired_count=0,stall_count=0,load_stall_count=0;
        assign flag_stall_count=0,flush_count=0,forward_count=0,flag_forward_count=0,fault_pc=0;
        assign debug_r0=cpu.u_regs.regs[0],debug_r1=cpu.u_regs.regs[1],debug_r3=cpu.u_regs.regs[3];
    end else begin:g_pipeline
        arm_pipeline_cpu #(.ENABLE_FORWARDING(CORE==1)) cpu(.*);
        assign debug_r0=cpu.u_regs.regs[0],debug_r1=cpu.u_regs.regs[1],debug_r3=cpu.u_regs.regs[3];
    end endgenerate
endmodule

module pipeline_program_test #(parameter IMAGE=0,CORE=1)(input wire clk,
    output reg done=0,output integer checks=0,output reg [31:0] completed_cycles=0);
    reg reset=1;
    wire fault,trace_valid,trace_executed,trace_rd_we,trace_mem_req,trace_mem_we,trace_byte;
    wire [31:0] trace_pc,trace_instruction,trace_next_pc,trace_wdata,trace_mem_addr,trace_mem_wdata;
    wire [31:0] result_word,sum_word,status_word,fault_pc,expected_fault_pc;
    wire [31:0] cycle_count,retired_count,stall_count,load_stall_count;
    wire [31:0] flag_stall_count,flush_count,forward_count,flag_forward_count;
    wire [31:0] debug_r0,debug_r1,debug_r3;
    wire [3:0] trace_rd,trace_nzcv,nzcv;
    wire actual_store;
    integer retired=0,expected_stores=0,actual_stores=0,wall_cycles=0;
    pipeline_fixture #(.IMAGE(IMAGE),.CORE(CORE)) dut(.*);
    always @(posedge clk) begin
        if(reset) begin actual_stores<=0;wall_cycles<=0;end
        else if(!done) begin
            wall_cycles<=wall_cycles+1;
            if(actual_store)actual_stores<=actual_stores+1;
        end
    end
    task automatic check(input string label,input [31:0] actual,expected);
        if(actual!==expected)$fatal(1,"image=%0d core=%0d retire=%0d %s actual=%08h expected=%08h",IMAGE,CORE,retired,label,actual,expected);
        else checks++;
    endtask
    task automatic expect_trace(input [31:0] pc,inst,next_pc,executed,rd_we,rd,wdata,
                                mem_req,mem_we,byte_access,mem_addr,mem_wdata,flags);
        integer waited;
        waited=0;
        do begin
            @(posedge clk);#1;waited++;
            if(fault)$fatal(1,"Unexpected fault image=%0d core=%0d pc=%08h",IMAGE,CORE,fault_pc);
            if(waited>40)$fatal(1,"Retirement stalled image=%0d core=%0d",IMAGE,CORE);
        end while(!trace_valid);
        check("valid",trace_valid,1);check("PC",trace_pc,pc);check("instruction",trace_instruction,inst);
        check("next PC",trace_next_pc,next_pc);check("condition",trace_executed,executed);
        check("reg write",trace_rd_we,rd_we);check("rd",trace_rd,rd);check("wdata",trace_wdata,wdata);
        check("mem req",trace_mem_req,mem_req);check("mem write",trace_mem_we,mem_we);
        check("byte",trace_byte,byte_access);check("address",trace_mem_addr,mem_addr);
        check("store data",trace_mem_wdata,mem_wdata);check("NZCV",trace_nzcv,flags);
        retired++;expected_stores+=mem_we;
    endtask
    initial begin
        repeat(3)@(posedge clk);@(negedge clk);reset=0;
        if(IMAGE==0)begin
            `include "demo_expected.vh"
        end else if(IMAGE==1)begin
            `include "stress_expected.vh"
        end else begin
            `include "hazards_expected.vh"
        end
        check("physical store count",actual_stores,expected_stores);
        if(IMAGE!=1)begin
            check("result",result_word,12);check("sum",sum_word,15);check("status",status_word,1);
        end
        if(CORE!=0)begin
            check("retired counter",retired_count,retired);check("cycle counter",cycle_count,wall_cycles);
            if(IMAGE==2&&CORE==1)begin
                if(load_stall_count<3||forward_count==0||flag_forward_count==0||flush_count==0)
                    $fatal(1,"Hazard test did not exercise all mechanisms");
            end
        end
        completed_cycles=wall_cycles;
        $display("PIPE PROGRAM PASSED: image=%0d core=%0d retired=%0d cycles=%0d stalls=%0d load_stalls=%0d flag_stalls=%0d redirects=%0d forwards=%0d flag_forwards=%0d checks=%0d",IMAGE,CORE,retired,wall_cycles,stall_count,load_stall_count,flag_stall_count,flush_count,forward_count,flag_forward_count,checks);
        done=1;
    end
endmodule
