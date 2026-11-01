module board_button #(parameter integer DEBOUNCE=10000)(input wire clk,input wire pin,output reg pressed=0,output reg pulse=0);
 (* ASYNC_REG="TRUE" *) reg[1:0] sync=0;
 reg[31:0] count=0;
 always @(posedge clk) begin
  sync<={sync[0],pin};pulse<=0;
  if(sync[1]==pressed) count<=0;
  else if(count==DEBOUNCE-1) begin count<=0;pressed<=sync[1];pulse<=sync[1];end
  else count<=count+1;
 end
endmodule
