module id_ex(
	input wire clk,
	input wire rst,
	input wire[`AluOpBus] id_aluop,
	input wire[`RegBus] id_r1,
	input wire[`RegBus] id_r2,
	input wire[`RegAddrBus] id_w_addr,
	input wire id_w_req,
	input wire[`InstAddrBus] id_pc,
	input wire[`RegBus] id_offset,

	input wire[`StallBus] stall_state,

	input wire b_flag_i,

	output reg[`AluOpBus] ex_aluop,
	output reg[`RegBus] ex_r1,
	output reg[`RegBus] ex_r2,
	output reg[`RegAddrBus] ex_w_addr,
	output reg[`InstAddrBus] ex_pc,
	output reg ex_w_req,
	output reg[`RegBus] ex_offset
);

always @(posedge clk) begin
	if(rst==`RstEnable)begin
		ex_aluop<=`EX_NOP;
		ex_r1<=`ZeroWord;
		ex_r2<=`ZeroWord;
		ex_w_addr<=`NOPRegAddr;
		ex_w_req<=`False;
		ex_pc<=`ZeroWord;
		ex_offset<=`ZeroWord;
	end else if(stall_state[2]==`False) begin
		if(stall_state[1]==`False && b_flag_i!=`True) begin
			ex_aluop<=id_aluop;
			ex_r1<=id_r1;
			ex_r2<=id_r2;
			ex_w_addr<=id_w_addr;
			ex_w_req<=id_w_req;
			ex_pc<=id_pc;
			ex_offset<=id_offset;
		end else begin
			ex_aluop<=`EX_NOP;
			ex_r1<=`ZeroWord;
			ex_r2<=`ZeroWord;
			ex_w_addr<=`NOPRegAddr;
			ex_w_req<=`False;
			ex_pc<=`ZeroWord;
			ex_offset<=`ZeroWord;
		end
	end
end
endmodule