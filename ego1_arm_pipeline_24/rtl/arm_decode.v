`timescale 1ns/1ps
// Decode explicit source usage: ARM R0 is writable; R15 is per-instruction PC+8.
module arm_decode(input wire [31:0] instruction,
    output wire bx,branch,memory,dp_legal,memory_legal,legal,
    output wire [3:0] opcode,ra,rb,rd,
    output wire use_a,use_b,use_flags,may_write_rd,may_write_flags,
    output wire mdu,output wire [1:0] mdu_op);
    assign bx=(instruction[27:4]==24'h12fff1);
    assign branch=(instruction[27:25]==3'b101);
    assign memory=(instruction[27:26]==2'b01);
    wire mul_encoding=(instruction[27:21]==7'b0000000)&&
        (instruction[15:12]==0)&&(instruction[7:4]==4'h9);
    wire sdiv_encoding=(instruction[27:20]==8'h71)&&
        (instruction[15:12]==4'hf)&&(instruction[7:4]==4'h1);
    wire udiv_encoding=(instruction[27:20]==8'h73)&&
        (instruction[15:12]==4'hf)&&(instruction[7:4]==4'h1);
    assign mdu=(mul_encoding||sdiv_encoding||udiv_encoding)&&
        (instruction[19:16]!=15)&&(instruction[11:8]!=15)&&(instruction[3:0]!=15);
    assign mdu_op=mul_encoding?2'd0:sdiv_encoding?2'd1:2'd2;
    wire dp=(instruction[27:26]==2'b00)&&!bx;
    assign opcode=instruction[24:21];
    wire compare=(opcode==8)||(opcode==10)||(opcode==11);
    wire move=(opcode==13)||(opcode==15);
    wire arithmetic=(opcode==2)||(opcode==3)||(opcode==4)||(opcode==5)||
                    (opcode==6)||(opcode==10)||(opcode==11);
    wire opcode_ok=(opcode==0)||(opcode==1)||(opcode==2)||(opcode==3)||
        (opcode==4)||(opcode==5)||(opcode==6)||compare||
        (opcode==12)||move||(opcode==14);
    assign dp_legal=dp&&opcode_ok&&(instruction[25]||!instruction[4])&&
        (compare?(instruction[20]&&(instruction[15:12]==0)):(instruction[15:12]!=15))&&
        (!move||(instruction[19:16]==0));
    assign memory_legal=memory&&!instruction[25]&&instruction[24]&&!instruction[21]&&
        (instruction[15:12]!=15);
    assign legal=bx||branch||dp_legal||memory_legal||mdu;
    assign ra=(bx||mdu)?instruction[3:0]:instruction[19:16];
    assign rb=mdu?instruction[11:8]:memory?instruction[15:12]:instruction[3:0];
    assign rd=mdu?instruction[19:16]:branch?4'd14:instruction[15:12];
    assign use_a=mdu||bx||memory_legal||(dp_legal&&!move);
    assign use_b=mdu||(memory_legal&&!instruction[20])||(dp_legal&&!instruction[25]);
    assign may_write_rd=(dp_legal&&!compare)||(memory_legal&&instruction[20])||
                        (branch&&instruction[24])||mdu;
    assign may_write_flags=(dp_legal&&(instruction[20]||compare))||
                           (mdu&&mul_encoding&&instruction[20]);
    // Logical S operations preserve old V; RRX and ADC/SBC also consume old C.
    assign use_flags=(instruction[31:28]<14)||(mdu&&mul_encoding&&instruction[20])||
        (dp_legal&&((opcode==5)||(opcode==6)||
        (may_write_flags&&!arithmetic)||
        (!instruction[25]&&(instruction[11:4]==8'h06))));
endmodule
