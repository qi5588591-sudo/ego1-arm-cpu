`timescale 1ns/1ps
module arm_single_cycle_cpu(
    input wire clk,reset,input wire [31:0] instruction,input wire instruction_valid,
    input wire [31:0] data_rdata,input wire data_address_valid,
    output reg [31:0] pc,output reg [3:0] nzcv,output reg fault,
    output wire data_req,data_we,data_byte,output wire [31:0] data_addr,data_wdata,
    output reg trace_valid,trace_executed,trace_rd_we,trace_mem_req,trace_mem_we,trace_byte,
    output reg [31:0] trace_pc,trace_instruction,trace_next_pc,trace_wdata,
    output reg [31:0] trace_mem_addr,trace_mem_wdata,
    output reg [3:0] trace_rd,trace_nzcv
);
    wire cond_pass;
    arm_condition u_condition(.cond(instruction[31:28]),.nzcv(nzcv),.passed(cond_pass));
    wire bx=(instruction[27:4]==24'h12fff1);
    wire branch=(instruction[27:25]==3'b101);
    wire memory=(instruction[27:26]==2'b01);
    wire dp=(instruction[27:26]==2'b00)&&!bx;
    wire [3:0] opcode=instruction[24:21];
    wire compare=(opcode==8)||(opcode==10)||(opcode==11);
    wire move=(opcode==13)||(opcode==15);
    wire opcode_ok=(opcode==0)||(opcode==1)||(opcode==2)||(opcode==3)||
        (opcode==4)||(opcode==5)||(opcode==6)||compare||
        (opcode==12)||move||(opcode==14);
    wire dp_legal=dp&&opcode_ok&&(instruction[25]||!instruction[4])&&
        (compare?(instruction[20]&&(instruction[15:12]==0)):(instruction[15:12]!=15))&&
        (!move||(instruction[19:16]==0));
    wire memory_legal=memory&&!instruction[25]&&instruction[24]&&!instruction[21]&&
        (instruction[15:12]!=15);
    wire legal=bx||branch||dp_legal||memory_legal;
    wire [3:0] ra=bx?instruction[3:0]:instruction[19:16];
    wire [3:0] rb=memory?instruction[15:12]:instruction[3:0];
    wire [31:0] a,b,operand2,alu_result;
    wire shifter_carry;
    wire [3:0] alu_flags;
    wire [31:0] sequential_pc=pc+32'd4;
    wire [31:0] branch_pc=pc+32'd8+{{6{instruction[23]}},instruction[23:0],2'b00};
    wire [31:0] next_pc=cond_pass&&branch?branch_pc:cond_pass&&bx? a:sequential_pc;
    wire branch_bad=bx&&(a[1:0]!=0);
    wire active=!reset&&!fault;
    wire current_error=!instruction_valid||(pc[1:0]!=0)||(instruction[31:28]==15)||
        (cond_pass&&(!legal||branch_bad||(memory&&!data_address_valid)));
    wire retire=active&&!current_error;
    wire execute=retire&&cond_pass;
    wire rd_we=execute&&((dp_legal&&!compare)||(memory_legal&&instruction[20])||
                         (branch&&instruction[24]));
    wire [3:0] rd=branch?4'd14:instruction[15:12];
    wire [31:0] writeback=branch?sequential_pc:memory?data_rdata:alu_result;
    wire flags_we=execute&&dp_legal&&(instruction[20]||compare);
    arm_regfile u_regs(.clk(clk),.reset(reset),.we(rd_we),.ra(ra),.rb(rb),
        .wd(rd),.wdata(writeback),.pc(pc),.a(a),.b(b));
    arm_operand2 u_operand2(.immediate(instruction[25]),.encoding(instruction[11:0]),
        .rm_value(b),.carry_in(nzcv[1]),.value(operand2),.carry_out(shifter_carry));
    arm_alu u_alu(.opcode(opcode),.a(a),.b(operand2),.old_flags(nzcv),
        .shifter_carry(shifter_carry),.result(alu_result),.new_flags(alu_flags));
    assign data_req=active&&cond_pass&&memory_legal;
    assign data_we=execute&&memory_legal&&!instruction[20];
    assign data_byte=instruction[22];
    assign data_addr=instruction[23]?a+{20'd0,instruction[11:0]}:a-{20'd0,instruction[11:0]};
    assign data_wdata=b;
    always @(posedge clk) begin
        if(reset) begin
            pc<=0; nzcv<=0; fault<=0;
            trace_valid<=0; trace_executed<=0; trace_rd_we<=0;
            trace_mem_req<=0; trace_mem_we<=0; trace_byte<=0;
            trace_pc<=0; trace_instruction<=0; trace_next_pc<=0;
            trace_wdata<=0; trace_mem_addr<=0; trace_mem_wdata<=0;
            trace_rd<=0; trace_nzcv<=0;
        end else begin
            if(active&&current_error) fault<=1;
            if(retire) pc<=next_pc;
            if(flags_we) nzcv<=alu_flags;
            trace_valid<=retire; trace_executed<=execute;
            trace_rd_we<=rd_we;
            trace_mem_req<=retire&&data_req; trace_mem_we<=data_we;
            trace_byte<=retire&&data_req&&data_byte;
            if(retire) begin
                trace_pc<=pc; trace_instruction<=instruction; trace_next_pc<=next_pc;
                trace_rd<=rd_we?rd:4'd0; trace_wdata<=rd_we?writeback:32'd0;
                trace_mem_addr<=data_req?data_addr:32'd0;
                trace_mem_wdata<=data_we?(data_byte?{24'd0,b[7:0]}:b):32'd0;
                trace_nzcv<=flags_we?alu_flags:nzcv;
            end
        end
    end
endmodule
