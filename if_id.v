module if_id(
	input wire clk,
	input wire rst,

	input wire[`InstAddrBus] if_pc,
	input wire[`InstBus] if_inst,

	input wire[`StallBus] stall_state,

	input wire b_flag_i,

	output reg[`InstAddrBus] id_pc,
	output reg[`InstBus] id_inst
);

always @(posedge clk) begin
	if(rst==`RstEnable) begin
		id_inst<=`ZeroWord;
		id_pc<=`ZeroWord;
	end else if (stall_state[1]==`False) begin
		if(b_flag_i) begin
			id_inst<=`ZeroWord;
			id_pc<=`ZeroWord;
		end else if(stall_state[0]==`False) begin
			id_inst<=if_inst;
			id_pc<=if_pc;
		end else begin
			id_inst<=`ZeroWord;
			id_pc<=`ZeroWord;
		end
	end
end
endmodule