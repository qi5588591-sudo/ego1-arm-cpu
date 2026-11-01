`timescale 1ns/1ps
// 256-byte RAM at 0x1000..0x10ff, little endian, four byte write lanes.
module arm_data_ram(input wire clk,reset,we,byte_access,
    input wire [31:0] address,wdata,output wire [31:0] rdata,
    output wire address_valid,output reg [31:0] result_word,sum_word,status_word);
    (* ram_style="distributed" *) reg [7:0] lane0[0:63],lane1[0:63],lane2[0:63],lane3[0:63];
    wire [5:0] index=address[7:2];
    wire [31:0] old_word={lane3[index],lane2[index],lane1[index],lane0[index]};
    wire [31:0] selected_byte=(old_word>>{address[1:0],3'b000})&32'hff;
    wire [31:0] byte_mask=32'hff<<{address[1:0],3'b000};
    wire [31:0] merged=byte_access?(old_word&~byte_mask)|
        ({24'd0,wdata[7:0]}<<{address[1:0],3'b000}):wdata;
    assign address_valid=(address[31:8]==24'h000010)&&(byte_access||(address[1:0]==0));
    assign rdata=address_valid?(byte_access?selected_byte:old_word):32'd0;
    integer i;
    initial begin
        for(i=0;i<64;i=i+1) begin lane0[i]=0; lane1[i]=0; lane2[i]=0; lane3[i]=0; end
        result_word=0; sum_word=0; status_word=0;
    end
    always @(posedge clk) if(!reset&&we&&address_valid) begin
        if(!byte_access||address[1:0]==0) lane0[index]<=byte_access?wdata[7:0]:wdata[7:0];
        if(!byte_access||address[1:0]==1) lane1[index]<=byte_access?wdata[7:0]:wdata[15:8];
        if(!byte_access||address[1:0]==2) lane2[index]<=byte_access?wdata[7:0]:wdata[23:16];
        if(!byte_access||address[1:0]==3) lane3[index]<=byte_access?wdata[7:0]:wdata[31:24];
        if(index==0) result_word<=merged;
        if(index==1) sum_word<=merged;
        if(index==2) status_word<=merged;
    end
endmodule
