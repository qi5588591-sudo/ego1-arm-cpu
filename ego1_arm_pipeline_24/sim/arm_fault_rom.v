`timescale 1ns/1ps
module arm_fault_rom #(parameter CASE_ID=0)(input wire[31:0] address,output reg[31:0] instruction,fault_address,output reg valid);
    always @* begin instruction=0;fault_address=0;valid=0;case(CASE_ID)
        0: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he7f000f0; valid=1'b1; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        1: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he5902000; valid=1'b1; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        2: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he59a2001; valid=1'b1; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        3: begin fault_address=32'h0000001c; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he3a09001; valid=1'b1; end
            32'h0000001c: begin instruction=32'he12fff19; valid=1'b1; end
            32'h00000020: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000024: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000028: begin instruction=32'he2903001; valid=1'b1; end
            32'h0000002c: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000030: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        4: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'hf3a00001; valid=1'b1; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        5: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he3a0f001; valid=1'b1; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        6: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he1a01210; valid=1'b1; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        7: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he1a00000; valid=1'b0; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        8: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he4901004; valid=1'b1; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        9: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he5c00000; valid=1'b1; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        10: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he00f0190; valid=1'b1; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        11: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he002019f; valid=1'b1; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        12: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he0020f90; valid=1'b1; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        13: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he71ff110; valid=1'b1; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        14: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he712f11f; valid=1'b1; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        15: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he732ff10; valid=1'b1; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        16: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he0220190; valid=1'b1; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        17: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he0021190; valid=1'b1; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        18: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he7120110; valid=1'b1; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        19: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he732f190; valid=1'b1; end
            32'h0000001c: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000020: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000024: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        20: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he5902000; valid=1'b1; end
            32'h0000001c: begin instruction=32'he0030190; valid=1'b1; end
            32'h00000020: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000024: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000028: begin instruction=32'he2903001; valid=1'b1; end
            32'h0000002c: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000030: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        21: begin fault_address=32'h00000018; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he7f000f0; valid=1'b1; end
            32'h0000001c: begin instruction=32'he0030190; valid=1'b1; end
            32'h00000020: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000024: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000028: begin instruction=32'he2903001; valid=1'b1; end
            32'h0000002c: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000030: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
        22: begin fault_address=32'h00000020; case(address)
            32'h00000000: begin instruction=32'he3a0a000; valid=1'b1; end
            32'h00000004: begin instruction=32'he38aaa01; valid=1'b1; end
            32'h00000008: begin instruction=32'he3a0002a; valid=1'b1; end
            32'h0000000c: begin instruction=32'he58a0000; valid=1'b1; end
            32'h00000010: begin instruction=32'he2801001; valid=1'b1; end
            32'h00000014: begin instruction=32'he350002a; valid=1'b1; end
            32'h00000018: begin instruction=32'he3a06003; valid=1'b1; end
            32'h0000001c: begin instruction=32'he0020690; valid=1'b1; end
            32'h00000020: begin instruction=32'he7f000f0; valid=1'b1; end
            32'h00000024: begin instruction=32'hea000000; valid=1'b1; end
            32'h00000028: begin instruction=32'he58a0008; valid=1'b1; end
            32'h0000002c: begin instruction=32'he2903001; valid=1'b1; end
            32'h00000030: begin instruction=32'he58a0008; valid=1'b1; end
            32'h00000034: begin instruction=32'heafffffe; valid=1'b1; end
            default: begin valid=0;instruction=0;end
        endcase end
    default:begin end
    endcase end
endmodule
