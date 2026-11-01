module showcase_catalog(input wire [4:0] selected,input wire[31:0] trace_pc,
 output reg found,output reg[4:0] record_index,
 output reg npages,output reg[2:0] p0_kind,p1_kind,p2_kind,
 output reg[63:0] p0_lanes,p1_lanes,p2_lanes,num_lanes,
 output reg[31:0] expected_ins,expected_value,expected_mem,expected_next,
 output reg[3:0] expected_flags);
 always @* begin found=0;record_index=0;case(trace_pc)
 32'h00000008:begin found=1;record_index=5'd0;end
 32'h0000001c:begin found=1;record_index=5'd1;end
 32'h00000030:begin found=1;record_index=5'd2;end
 32'h00000044:begin found=1;record_index=5'd3;end
 32'h0000005c:begin found=1;record_index=5'd4;end
 32'h00000078:begin found=1;record_index=5'd5;end
 32'h00000090:begin found=1;record_index=5'd6;end
 32'h000000a0:begin found=1;record_index=5'd7;end
 32'h000000b0:begin found=1;record_index=5'd8;end
 32'h000000c0:begin found=1;record_index=5'd9;end
 32'h000000d0:begin found=1;record_index=5'd10;end
 32'h000000f0:begin found=1;record_index=5'd11;end
 32'h000000f8:begin found=1;record_index=5'd12;end
 32'h00000100:begin found=1;record_index=5'd13;end
 32'h00000108:begin found=1;record_index=5'd14;end
 32'h0000010c:begin found=1;record_index=5'd15;end
 32'h00000124:begin found=1;record_index=5'd16;end
 32'h00000128:begin found=1;record_index=5'd17;end
 32'h00000138:begin found=1;record_index=5'd18;end
 32'h00000144:begin found=1;record_index=5'd19;end
 32'h000001d8:begin found=1;record_index=5'd20;end
 32'h00000160:begin found=1;record_index=5'd21;end
 32'h00000184:begin found=1;record_index=5'd22;end
 32'h000001a8:begin found=1;record_index=5'd23;end
 default:begin end endcase end
 always @* begin npages=0;p0_kind=0;p1_kind=0;p2_kind=0;p0_lanes=0;p1_lanes=0;p2_lanes=0;num_lanes=0;expected_ins=0;expected_value=0;expected_mem=0;expected_next=0;expected_flags=0;case(selected)
 5'd0:begin npages=1'b0;p0_kind=3'd0;p1_kind=3'd1;p2_kind=3'd0;p0_lanes=64'h3f063f3f3f3f3f07;p1_lanes=64'h0000000000000000;p2_lanes=64'h0000000000000000;num_lanes=64'h3f06000000000000;expected_ins=32'he3a05007;expected_value=32'h00000007;expected_mem=32'h00000000;expected_next=32'h0000000c;expected_flags=4'h0;end
 5'd1:begin npages=1'b1;p0_kind=3'd0;p1_kind=3'd0;p2_kind=3'd1;p0_lanes=64'h3f5b3f3f3f3f3f07;p1_lanes=64'h3f5b3f3f3f3f3f6d;p2_lanes=64'h0000000000000000;num_lanes=64'h3f5b000000000000;expected_ins=32'he2805005;expected_value=32'h0000000c;expected_mem=32'h00000000;expected_next=32'h00000020;expected_flags=4'h6;end
 5'd2:begin npages=1'b1;p0_kind=3'd0;p1_kind=3'd0;p2_kind=3'd1;p0_lanes=64'h3f4f3f3f3f3f065b;p1_lanes=64'h3f4f3f3f3f3f3f6d;p2_lanes=64'h0000000000000000;num_lanes=64'h3f4f000000000000;expected_ins=32'he2405005;expected_value=32'h00000007;expected_mem=32'h00000000;expected_next=32'h00000034;expected_flags=4'h6;end
 5'd3:begin npages=1'b1;p0_kind=3'd0;p1_kind=3'd0;p2_kind=3'd1;p0_lanes=64'h3f663f3f3f3f5b3f;p1_lanes=64'h3f663f3f3f3f3f07;p2_lanes=64'h0000000000000000;num_lanes=64'h3f66000000000000;expected_ins=32'he2605014;expected_value=32'h0000000d;expected_mem=32'h00000000;expected_next=32'h00000048;expected_flags=4'h6;end
 5'd4:begin npages=1'b1;p0_kind=3'd0;p1_kind=3'd0;p2_kind=3'd1;p0_lanes=64'h3f6d3f3f3f3f3f07;p1_lanes=64'h3f6d3f3f3f3f3f6d;p2_lanes=64'h0000000000000000;num_lanes=64'h3f6d000000000000;expected_ins=32'he2a05005;expected_value=32'h0000000d;expected_mem=32'h00000000;expected_next=32'h00000060;expected_flags=4'h6;end
 5'd5:begin npages=1'b1;p0_kind=3'd0;p1_kind=3'd0;p2_kind=3'd1;p0_lanes=64'h3f7d3f3f3f3f3f07;p1_lanes=64'h3f7d3f3f3f3f3f5b;p2_lanes=64'h0000000000000000;num_lanes=64'h3f7d000000000000;expected_ins=32'he2c05002;expected_value=32'h00000004;expected_mem=32'h00000000;expected_next=32'h0000007c;expected_flags=4'h8;end
 5'd6:begin npages=1'b1;p0_kind=3'd0;p1_kind=3'd0;p2_kind=3'd1;p0_lanes=64'h3f073f3f3f3f3f7d;p1_lanes=64'h3f073f3f3f3f3f4f;p2_lanes=64'h0000000000000000;num_lanes=64'h3f07000000000000;expected_ins=32'he0065007;expected_value=32'h00000002;expected_mem=32'h00000000;expected_next=32'h00000094;expected_flags=4'h6;end
 5'd7:begin npages=1'b1;p0_kind=3'd0;p1_kind=3'd0;p2_kind=3'd1;p0_lanes=64'h3f7f3f3f3f3f3f7d;p1_lanes=64'h3f7f3f3f3f3f3f4f;p2_lanes=64'h0000000000000000;num_lanes=64'h3f7f000000000000;expected_ins=32'he1865007;expected_value=32'h00000007;expected_mem=32'h00000000;expected_next=32'h000000a4;expected_flags=4'h6;end
 5'd8:begin npages=1'b1;p0_kind=3'd0;p1_kind=3'd0;p2_kind=3'd1;p0_lanes=64'h3f6f3f3f3f3f3f7d;p1_lanes=64'h3f6f3f3f3f3f3f4f;p2_lanes=64'h0000000000000000;num_lanes=64'h3f6f000000000000;expected_ins=32'he0265007;expected_value=32'h00000005;expected_mem=32'h00000000;expected_next=32'h000000b4;expected_flags=4'h6;end
 5'd9:begin npages=1'b1;p0_kind=3'd0;p1_kind=3'd0;p2_kind=3'd1;p0_lanes=64'h063f3f3f3f3f3f7d;p1_lanes=64'h063f3f3f3f3f3f4f;p2_lanes=64'h0000000000000000;num_lanes=64'h063f000000000000;expected_ins=32'he1c65007;expected_value=32'h00000004;expected_mem=32'h00000000;expected_next=32'h000000c4;expected_flags=4'h6;end
 5'd10:begin npages=1'b0;p0_kind=3'd0;p1_kind=3'd1;p2_kind=3'd0;p0_lanes=64'h06063f3f3f3f3f07;p1_lanes=64'h0000000000000000;p2_lanes=64'h0000000000000000;num_lanes=64'h0606000000000000;expected_ins=32'he3e05007;expected_value=32'hfffffff8;expected_mem=32'h00000000;expected_next=32'h000000d4;expected_flags=4'h6;end
 5'd11:begin npages=1'b1;p0_kind=3'd0;p1_kind=3'd0;p2_kind=3'd4;p0_lanes=64'h065b3f3f3f3f3f07;p1_lanes=64'h065b3f3f3f3f3f07;p2_lanes=64'h0000000000000000;num_lanes=64'h065b000000000000;expected_ins=32'he1500000;expected_value=32'h00000000;expected_mem=32'h00000000;expected_next=32'h000000f4;expected_flags=4'h6;end
 5'd12:begin npages=1'b1;p0_kind=3'd0;p1_kind=3'd0;p2_kind=3'd4;p0_lanes=64'h064f403f3f3f3f06;p1_lanes=64'h064f3f3f3f3f3f06;p2_lanes=64'h0000000000000000;num_lanes=64'h064f000000000000;expected_ins=32'he3760001;expected_value=32'h00000000;expected_mem=32'h00000000;expected_next=32'h000000fc;expected_flags=4'h6;end
 5'd13:begin npages=1'b1;p0_kind=3'd0;p1_kind=3'd0;p2_kind=3'd4;p0_lanes=64'h06663f3f3f3f3f7d;p1_lanes=64'h06663f3f3f3f3f5b;p2_lanes=64'h0000000000000000;num_lanes=64'h0666000000000000;expected_ins=32'he3160002;expected_value=32'h00000000;expected_mem=32'h00000000;expected_next=32'h00000104;expected_flags=4'h2;end
 5'd14:begin npages=1'b0;p0_kind=3'd0;p1_kind=3'd2;p2_kind=3'd0;p0_lanes=64'h066d3f3f063f3f3f;p1_lanes=64'h0000000000000000;p2_lanes=64'h0000000000000000;num_lanes=64'h066d000000000000;expected_ins=32'he58a2000;expected_value=32'h00000000;expected_mem=32'h0000000c;expected_next=32'h0000010c;expected_flags=4'h2;end
 5'd15:begin npages=1'b0;p0_kind=3'd0;p1_kind=3'd1;p2_kind=3'd0;p0_lanes=64'h067d3f3f063f3f3f;p1_lanes=64'h0000000000000000;p2_lanes=64'h0000000000000000;num_lanes=64'h067d000000000000;expected_ins=32'he59a3000;expected_value=32'h0000000c;expected_mem=32'h00000000;expected_next=32'h00000110;expected_flags=4'h2;end
 5'd16:begin npages=1'b0;p0_kind=3'd0;p1_kind=3'd2;p2_kind=3'd0;p0_lanes=64'h06073f3f063f063f;p1_lanes=64'h0000000000000000;p2_lanes=64'h0000000000000000;num_lanes=64'h0607000000000000;expected_ins=32'he5ca6010;expected_value=32'h00000000;expected_mem=32'h00000012;expected_next=32'h00000128;expected_flags=4'h6;end
 5'd17:begin npages=1'b0;p0_kind=3'd0;p1_kind=3'd1;p2_kind=3'd0;p0_lanes=64'h067f3f3f063f063f;p1_lanes=64'h0000000000000000;p2_lanes=64'h0000000000000000;num_lanes=64'h067f000000000000;expected_ins=32'he5da4010;expected_value=32'h00000012;expected_mem=32'h00000000;expected_next=32'h0000012c;expected_flags=4'h6;end
 5'd18:begin npages=1'b0;p0_kind=3'd6;p1_kind=3'd3;p2_kind=3'd0;p0_lanes=64'h0000000000000000;p1_lanes=64'h0000000000000000;p2_lanes=64'h0000000000000000;num_lanes=64'h066f000000000000;expected_ins=32'hea000001;expected_value=32'h00000000;expected_mem=32'h00000000;expected_next=32'h00000144;expected_flags=4'h6;end
 5'd19:begin npages=1'b1;p0_kind=3'd6;p1_kind=3'd3;p2_kind=3'd5;p0_lanes=64'h0000000000000000;p1_lanes=64'h0000000000000000;p2_lanes=64'h0000000000000000;num_lanes=64'h5b3f000000000000;expected_ins=32'heb000023;expected_value=32'h00000148;expected_mem=32'h00000000;expected_next=32'h000001d8;expected_flags=4'h6;end
 5'd20:begin npages=1'b0;p0_kind=3'd6;p1_kind=3'd3;p2_kind=3'd0;p0_lanes=64'h0000000000000000;p1_lanes=64'h0000000000000000;p2_lanes=64'h0000000000000000;num_lanes=64'h5b06000000000000;expected_ins=32'he12fff1e;expected_value=32'h00000000;expected_mem=32'h00000000;expected_next=32'h00000148;expected_flags=4'h6;end
 5'd21:begin npages=1'b1;p0_kind=3'd0;p1_kind=3'd0;p2_kind=3'd1;p0_lanes=64'h5b5b3f3f3f3f3f7d;p1_lanes=64'h5b5b3f3f3f3f3f4f;p2_lanes=64'h0000000000000000;num_lanes=64'h5b5b000000000000;expected_ins=32'he0050796;expected_value=32'h00000012;expected_mem=32'h00000000;expected_next=32'h00000164;expected_flags=4'h6;end
 5'd22:begin npages=1'b1;p0_kind=3'd0;p1_kind=3'd0;p2_kind=3'd1;p0_lanes=64'h5b4f403f3f3f3f07;p1_lanes=64'h5b4f3f3f3f3f3f4f;p2_lanes=64'h0000000000000000;num_lanes=64'h5b4f000000000000;expected_ins=32'he715f716;expected_value=32'hfffffffe;expected_mem=32'h00000000;expected_next=32'h00000188;expected_flags=4'h6;end
 5'd23:begin npages=1'b1;p0_kind=3'd0;p1_kind=3'd0;p2_kind=3'd1;p0_lanes=64'h5b663f3f3f3f5b06;p1_lanes=64'h5b663f3f3f3f3f4f;p2_lanes=64'h0000000000000000;num_lanes=64'h5b66000000000000;expected_ins=32'he735f716;expected_value=32'h00000007;expected_mem=32'h00000000;expected_next=32'h000001ac;expected_flags=4'h6;end
 default:begin end endcase end
endmodule
