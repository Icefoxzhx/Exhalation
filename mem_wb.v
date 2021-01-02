module mem_wb(
	input wire clk,
	input wire rst,
	input wire rdy,
	
	input wire[`RegAddrBus] mem_w_addr,
	input wire mem_w_req,
	input wire[`RegBus] mem_w_data,

	input wire[`StallBus] stall_state,

	output reg[`RegAddrBus] wb_w_addr,
	output reg wb_w_req,
	output reg[`RegBus] wb_w_data
);
always @(posedge clk) begin
	if(rdy==`True) begin
		if(rst==`True) begin
			wb_w_addr<=`NOPRegAddr;
			wb_w_req<=`False;
			wb_w_data<=`ZeroWord;
		end else if(stall_state[3]==`False)begin
			wb_w_addr<=mem_w_addr;
			wb_w_req<=mem_w_req;
			wb_w_data<=mem_w_data;
		end
	end
end
endmodule