`timescale 1ns/1ps
module arm_fault_probe #(parameter CASE_ID=0)(input wire clk,output reg done=0,output integer checks=0);
    reg reset=1;
    wire [31:0] pc,data_addr,data_wdata;
    wire [3:0] nzcv;
    wire fault,data_req,data_we,data_byte;
    wire address_valid=(data_addr[31:8]==24'h10)&&(data_byte||data_addr[1:0]==0);
    reg [31:0] instruction;
    wire instruction_valid=(CASE_ID!=1);
    wire [31:0] data_rdata=0;
    wire data_address_valid=address_valid;
    wire trace_valid,trace_executed,trace_rd_we,trace_mem_req,trace_mem_we,trace_byte;
    wire [31:0] trace_pc,trace_instruction,trace_next_pc,trace_wdata,trace_mem_addr,trace_mem_wdata;
    wire [3:0] trace_rd,trace_nzcv;
    reg [31:0] stopped_pc;
    always_comb begin
        case(CASE_ID)
            0: instruction=32'he7f000f0; // UDF, unsupported encoding
            1: instruction=32'he3a00001; // fetch is invalid
            2: instruction=32'he5901000; // LDR from 0, outside data RAM
            3: instruction=32'he59f1ff9; // LDR from 0x1001, misaligned
            4: instruction=(pc==0)?32'he3a00001:32'he12fff10; // BX Thumb target
            5: instruction=32'hf3a00001; // unconditional-extension space unsupported
            6: instruction=32'he3a0f001; // MOV PC unsupported
            7: instruction=32'he4901004; // post-index LDR unsupported
            8: instruction=32'he1a01210; // register-controlled shift unsupported
            9: instruction=32'he5c01000; // STRB outside data RAM
            default: instruction=0;
        endcase
    end
    arm_single_cycle_cpu dut(.*);
    task automatic require(input bit ok,input string label);
        if(!ok) $fatal(1,"Fault case %0d: %s",CASE_ID,label);else checks++;
    endtask
    initial begin
        repeat(3) @(posedge clk);@(negedge clk);reset=0;
        repeat(3) @(posedge clk);#1;
        require(fault===1,"invalid operation faults");stopped_pc=pc;
        repeat(3) begin
            @(posedge clk);#1;
            require(pc===stopped_pc,"fault holds PC");
            require(data_we===0 && trace_valid===0 && trace_rd_we===0 && trace_mem_we===0,"no fault side effects");
        end
        @(negedge clk);reset=1;@(posedge clk);#1;
        require(fault===0 && pc===0 && nzcv===0,"reset clears fault/PC/flags");
        done=1;
    end
endmodule

module arm_condition_test(output reg done=0,output integer checks=0);
    reg [3:0] cond=0,nzcv=0;
    wire passed;
    integer f,c;
    reg expected;
    arm_condition dut(.*);
    initial begin
        for(f=0;f<16;f++) for(c=0;c<16;c++) begin
            cond=c;nzcv=f;#1;
            case(c)
                0: expected=(f&4)!=0;1:expected=(f&4)==0;
                2: expected=(f&2)!=0;3:expected=(f&2)==0;
                4: expected=(f&8)!=0;5:expected=(f&8)==0;
                6: expected=(f&1)!=0;7:expected=(f&1)==0;
                8: expected=(f&6)==2;9:expected=(f&2)==0||(f&4)!=0;
                10:expected=((f>>3)&1)==(f&1);11:expected=((f>>3)&1)!=(f&1);
                12:expected=(f&4)==0&&((f>>3)&1)==(f&1);
                13:expected=(f&4)!=0||((f>>3)&1)!=(f&1);
                14:expected=1;15:expected=0;
            endcase
            if(passed!==expected) $fatal(1,"Condition %0d NZCV=%h",c,f);
            checks++;
        end
        done=1;
    end
endmodule
