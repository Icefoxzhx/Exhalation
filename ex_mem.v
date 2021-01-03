module ex_mem(
	input wire clk,
	input wire rst,
	input wire rdy,
	
	input wire[`RegAddrBus] ex_w_addr,
	input wire ex_w_req,
	input wire[`RegBus] ex_w_data,

	input wire[`MemBus] ex_mem_addr,
	input wire[`AluOpBus] ex_aluop,

	input wire[`StallBus] stall_state,

	output reg[`RegAddrBus] mem_w_addr,
	output reg mem_w_req,
	output reg[`RegBus] mem_w_data,
	output reg[`MemBus] mem_mem_addr,
	output reg[`AluOpBus] mem_aluop
);

always @(posedge clk) begin
	if(rst==`True) begin
		mem_w_addr<=`NOPRegAddr;
		mem_w_req<=`False;
		mem_w_data<=`ZeroWord;
		mem_aluop<=`EX_NOP;
		mem_mem_addr<=`ZeroWord;
	end else if(rdy==`True) begin
		if(stall_state[3]==`False) begin
			mem_w_addr<=ex_w_addr;
			mem_w_req<=ex_w_req;
			mem_w_data<=ex_w_data;
			mem_aluop<=ex_aluop;
			mem_mem_addr<=ex_mem_addr;
		end
	end
end
endmodule