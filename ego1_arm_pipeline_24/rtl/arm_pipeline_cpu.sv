`timescale 1ns/1ps
module arm_pipeline_cpu #(parameter ENABLE_FORWARDING=1)(
    input wire clk,reset,input wire [31:0] instruction,input wire instruction_valid,
    input wire [31:0] data_rdata,input wire data_address_valid,
    output reg [31:0] pc,output reg [3:0] nzcv,output reg fault,
    output reg [31:0] fault_pc,
    output wire data_req,data_we,data_byte,output wire [31:0] data_addr,data_wdata,
    output reg trace_valid,trace_executed,trace_rd_we,trace_mem_req,trace_mem_we,trace_byte,
    output reg [31:0] trace_pc,trace_instruction,trace_next_pc,trace_wdata,
    output reg [31:0] trace_mem_addr,trace_mem_wdata,
    output reg [3:0] trace_rd,trace_nzcv,
    output reg [31:0] cycle_count,retired_count,stall_count,load_stall_count,
    output reg [31:0] flag_stall_count,flush_count,forward_count,flag_forward_count
);
    typedef struct packed {
        logic valid,fetch_ok;
        logic [31:0] pc,ins;
    } fd_t;
    typedef struct packed {
        logic valid,fetch_ok,legal,bx,branch,memory,dp,mem_legal,mdu;
        logic [1:0] mdu_op;
        logic use_a,use_b,use_flags,rd_write,flags_write;
        logic [3:0] opcode,ra,rb,rd;
        logic [31:0] pc,ins,a,b;
    } de_t;
    typedef struct packed {
        logic valid,error,executed,rd_we,flags_we,mem_req,mem_we,byte_access;
        logic [3:0] rd,new_flags;
        logic [31:0] pc,ins,next_pc,value,address,store_value;
    } mw_t;
    fd_t fd;
    de_t e;
    mw_t m,w;
    reg fault_pending;
    reg mdu_inflight;
    reg [3:0] mdu_saved_flags;
    reg [31:0] mdu_stall_count,mdu_start_count;

    wire d_bx,d_branch,d_memory,d_dp,d_mem_legal,d_legal;
    wire [3:0] d_opcode,d_ra,d_rb,d_rd;
    wire d_use_a,d_use_b,d_use_flags,d_rd_write,d_flags_write;
    wire d_mdu;
    wire [1:0] d_mdu_op;
    arm_decode u_decode(.instruction(fd.ins),.bx(d_bx),.branch(d_branch),.memory(d_memory),
        .dp_legal(d_dp),.memory_legal(d_mem_legal),.legal(d_legal),.opcode(d_opcode),
        .ra(d_ra),.rb(d_rb),.rd(d_rd),.use_a(d_use_a),.use_b(d_use_b),
        .use_flags(d_use_flags),.may_write_rd(d_rd_write),.may_write_flags(d_flags_write),
        .mdu(d_mdu),.mdu_op(d_mdu_op));

    wire active=!reset&&!fault;
    wire wb_error=w.valid&&w.error;
    wire wb_write=active&&w.valid&&!w.error&&w.rd_we;
    wire [31:0] id_a,id_b;
    arm_pipeline_regfile u_regs(.clk(clk),.reset(reset),.we(wb_write),.ra(d_ra),.rb(d_rb),
        .wd(w.rd),.wdata(w.value),.id_pc(fd.pc),.a(id_a),.b(id_b));

    // MEM owns the data port. The validity check is independent of write enable.
    assign data_req=active&&!wb_error&&m.valid&&!m.error&&m.mem_req;
    wire mem_error=m.valid&&(m.error||(data_req&&!data_address_valid));
    assign data_we=data_req&&m.mem_we&&!mem_error;
    assign data_addr=m.address;
    assign data_wdata=m.store_value;
    assign data_byte=m.byte_access;
    wire [31:0] mem_value=m.mem_req&&!m.mem_we?data_rdata:m.value;

    // Actual executed writers only. Newest producer has priority; loads cannot
    // forward their address as register data from EX/MEM.
    wire ma=ENABLE_FORWARDING&&m.valid&&!mem_error&&m.rd_we&&!m.mem_req&&
            e.use_a&&(e.ra!=15)&&(e.ra==m.rd);
    wire mb=ENABLE_FORWARDING&&m.valid&&!mem_error&&m.rd_we&&!m.mem_req&&
            e.use_b&&(e.rb!=15)&&(e.rb==m.rd);
    wire wa=ENABLE_FORWARDING&&w.valid&&!w.error&&w.rd_we&&e.use_a&&(e.ra!=15)&&(e.ra==w.rd);
    wire wb=ENABLE_FORWARDING&&w.valid&&!w.error&&w.rd_we&&e.use_b&&(e.rb!=15)&&(e.rb==w.rd);
    wire [31:0] ex_a=ma?m.value:wa?w.value:e.a;
    wire [31:0] ex_b=mb?m.value:wb?w.value:e.b;
    wire mf=ENABLE_FORWARDING&&m.valid&&!mem_error&&m.flags_we;
    wire wf=ENABLE_FORWARDING&&w.valid&&!w.error&&w.flags_we;
    wire [3:0] current_flags=mf?m.new_flags:wf?w.new_flags:nzcv;
    // Save predicate/partial-flag inputs before the older flag writers drain.
    wire [3:0] ex_flags=mdu_inflight?mdu_saved_flags:current_flags;
    wire condition_pass;
    arm_condition u_condition(.cond(e.ins[31:28]),.nzcv(ex_flags),.passed(condition_pass));
    wire [31:0] operand2,alu_result;
    wire shifter_carry;
    wire [3:0] alu_flags;
    arm_operand2 u_operand2(.immediate(e.ins[25]),.encoding(e.ins[11:0]),
        .rm_value(ex_b),.carry_in(ex_flags[1]),.value(operand2),.carry_out(shifter_carry));
    arm_alu u_alu(.opcode(e.opcode),.a(ex_a),.b(operand2),.old_flags(ex_flags),
        .shifter_carry(shifter_carry),.result(alu_result),.new_flags(alu_flags));
    wire ex_error=e.valid&&(!e.fetch_ok||e.pc[1:0]!=0||e.ins[31:28]==15||
        (condition_pass&&(!e.legal||(e.bx&&ex_a[1:0]!=0))));
    wire ex_execute=e.valid&&condition_pass&&!ex_error;
    wire mdu_busy,mdu_done;
    wire [31:0] mdu_result;
    wire mdu_cancel=reset||fault||wb_error||mem_error||fault_pending;
    wire mdu_start=active&&!fault_pending&&!wb_error&&!mem_error&&
        ex_execute&&e.mdu&&!mdu_inflight&&!mdu_busy;
    wire mdu_wait=ex_execute&&e.mdu&&!mdu_done;
    wire [3:0] mdu_flags={mdu_result[31],(mdu_result==0),mdu_saved_flags[1:0]};
    arm_mdu u_mdu(.clk(clk),.reset(mdu_cancel),.start(mdu_start),
        .op(e.mdu_op),.a(ex_a),.b(ex_b),.busy(mdu_busy),.done(mdu_done),.result(mdu_result));

    always @(posedge clk) begin
        if(mdu_cancel) begin mdu_inflight<=0;mdu_saved_flags<=0;end
        else if(mdu_start) begin mdu_inflight<=1;mdu_saved_flags<=current_flags;end
        else if(mdu_done) mdu_inflight<=0;
    end
    wire ex_rd_we=ex_execute&&e.rd_write;
    wire ex_flags_we=ex_execute&&e.flags_write;
    wire ex_load=ex_execute&&e.mem_legal&&e.ins[20];
    wire [31:0] ex_next_pc=ex_execute&&e.branch?
        e.pc+32'd8+{{6{e.ins[23]}},e.ins[23:0],2'b00}:
        ex_execute&&e.bx?ex_a:e.pc+32'd4;
    wire redirect=active&&!fault_pending&&!wb_error&&!mem_error&&
                  ex_execute&&(e.branch||e.bx);
    wire [31:0] ex_address=e.ins[23]?ex_a+{20'd0,e.ins[11:0]}:
                                                     ex_a-{20'd0,e.ins[11:0]};

    wire dep_e=fd.valid&&e.valid&&ex_rd_we&&
        ((d_use_a&&d_ra!=15&&d_ra==e.rd)||(d_use_b&&d_rb!=15&&d_rb==e.rd));
    wire dep_m=fd.valid&&m.valid&&!mem_error&&m.rd_we&&
        ((d_use_a&&d_ra!=15&&d_ra==m.rd)||(d_use_b&&d_rb!=15&&d_rb==m.rd));
    wire load_hazard=dep_e&&ex_load;
    wire flags_hazard=!ENABLE_FORWARDING&&fd.valid&&d_use_flags&&
                      ((e.valid&&ex_flags_we)||(m.valid&&!mem_error&&m.flags_we));
    wire stall=ENABLE_FORWARDING?load_hazard:(dep_e||dep_m||flags_hazard);

    always @(posedge clk) begin
        if(reset) begin
            pc<=0;nzcv<=0;fault<=0;fault_pc<=0;fault_pending<=0;
            fd<='0;e<='0;m<='0;w<='0;
            trace_valid<=0;trace_executed<=0;trace_rd_we<=0;
            trace_mem_req<=0;trace_mem_we<=0;trace_byte<=0;
            trace_pc<=0;trace_instruction<=0;trace_next_pc<=0;trace_wdata<=0;
            trace_mem_addr<=0;trace_mem_wdata<=0;trace_rd<=0;trace_nzcv<=0;
            cycle_count<=0;retired_count<=0;stall_count<=0;load_stall_count<=0;
            flag_stall_count<=0;flush_count<=0;forward_count<=0;flag_forward_count<=0;
            mdu_stall_count<=0;mdu_start_count<=0;
        end else begin
            trace_valid<=0;trace_executed<=0;trace_rd_we<=0;
            trace_mem_req<=0;trace_mem_we<=0;trace_byte<=0;
            if(active) begin
                cycle_count<=cycle_count+1;
                // WB is the only architectural register/flag commit point.
                if(w.valid&&!w.error) begin
                    retired_count<=retired_count+1;
                    if(w.flags_we) nzcv<=w.new_flags;
                    trace_valid<=1;trace_executed<=w.executed;trace_rd_we<=w.rd_we;
                    trace_mem_req<=w.mem_req;trace_mem_we<=w.mem_we;trace_byte<=w.mem_req&&w.byte_access;
                    trace_pc<=w.pc;trace_instruction<=w.ins;trace_next_pc<=w.next_pc;
                    trace_rd<=w.rd_we?w.rd:4'd0;trace_wdata<=w.rd_we?w.value:32'd0;
                    trace_mem_addr<=w.mem_req?w.address:32'd0;
                    trace_mem_wdata<=w.mem_we?(w.byte_access?{24'd0,w.store_value[7:0]}:w.store_value):32'd0;
                    trace_nzcv<=w.flags_we?w.new_flags:nzcv;
                end
                if(wb_error) begin
                    fault<=1;fault_pc<=w.pc;fd<='0;e<='0;m<='0;w<='0;
                end else begin
                    // MEM always drains, including while ID is stalled.
                    w<=m;w.error<=mem_error;w.value<=mem_value;
                    w.mem_req<=data_req;w.mem_we<=data_we;
                    if(mem_error) begin
                        // An older MEM error wins over a younger EX redirect.
                        fault_pending<=1;fd<='0;e<='0;m<='0;
                    end else if(mdu_wait) begin
                        // Hold EX/ID/IF. Older MEM/WB instructions still drain.
                        // A bubble in MEM prevents duplicate stores or retirement.
                        m<='0;stall_count<=stall_count+1;
                        mdu_stall_count<=mdu_stall_count+1;
                        if(mdu_start) begin
                            mdu_start_count<=mdu_start_count+1;
                            if(ma||mb||wa||wb)forward_count<=forward_count+1;
                            if(e.use_flags&&(mf||wf))flag_forward_count<=flag_forward_count+1;
                        end
                    end else begin
                        m.valid<=e.valid;m.error<=ex_error;m.executed<=ex_execute;
                        m.pc<=e.pc;m.ins<=e.ins;m.next_pc<=ex_next_pc;
                        m.rd<=e.rd;m.rd_we<=ex_rd_we;m.flags_we<=ex_flags_we;
                        m.new_flags<=e.mdu?mdu_flags:alu_flags;
                        m.value<=e.mdu?mdu_result:e.branch?e.pc+32'd4:alu_result;
                        m.mem_req<=ex_execute&&e.mem_legal;
                        m.mem_we<=ex_execute&&e.mem_legal&&!e.ins[20];
                        m.byte_access<=e.ins[22];m.address<=ex_address;m.store_value<=ex_b;
                        if(ex_error) begin
                            fault_pending<=1;fd<='0;e<='0;
                        end else if(fault_pending) begin fd<='0;e<='0;end
                        else if(redirect) begin
                            pc<=ex_next_pc;fd<='0;e<='0;flush_count<=flush_count+1;
                        end else if(stall) begin
                            // Hold IF/ID and PC; bubble EX while the producer advances.
                            e<='0;stall_count<=stall_count+1;
                            if(load_hazard) load_stall_count<=load_stall_count+1;
                            if(flags_hazard) flag_stall_count<=flag_stall_count+1;
                        end else begin
                            fd.valid<=1;fd.fetch_ok<=instruction_valid;fd.pc<=pc;fd.ins<=instruction;
                            pc<=pc+32'd4;
                            e.valid<=fd.valid;e.fetch_ok<=fd.fetch_ok;e.pc<=fd.pc;e.ins<=fd.ins;
                            e.legal<=d_legal;e.bx<=d_bx;e.branch<=d_branch;e.memory<=d_memory;
                            e.mdu<=d_mdu;e.mdu_op<=d_mdu_op;
                            e.dp<=d_dp;e.mem_legal<=d_mem_legal;e.opcode<=d_opcode;
                            e.ra<=d_ra;e.rb<=d_rb;e.rd<=d_rd;
                            e.use_a<=d_use_a;e.use_b<=d_use_b;e.use_flags<=d_use_flags;
                            e.rd_write<=d_rd_write;e.flags_write<=d_flags_write;e.a<=id_a;e.b<=id_b;
                        end
                        if(e.valid&&!e.mdu&&!ex_error&&(ma||mb||wa||wb)) forward_count<=forward_count+1;
                        if(e.valid&&!e.mdu&&!ex_error&&e.use_flags&&(mf||wf)) flag_forward_count<=flag_forward_count+1;
                    end
                end
            end
        end
    end
endmodule
