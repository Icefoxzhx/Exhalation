module IF(
	input wire clk,
	input wire rst,
	input wire rdy,

	input wire ex_b_flag_i,
	input wire[`InstAddrBus] ex_b_tar_i,

	input wire taken_i,
	input wire[`InstAddrBus] P_b_tar_i,

	input wire[`InstBus] inst_i,
	input wire inst_ok,
	input wire[`InstAddrBus] inst_pc,

	input wire[`StallBus] stall_state,
	
	output reg[`InstAddrBus] pc_o,
	output reg[`InstBus] inst_o,
	
	output wire inst_fe,
	output reg[`InstAddrBus] inst_fpc,

	output reg taken_o,

	output reg if_stall
);

//I-cache
reg[`TagBus] tag[`ICacheLines-1:0];
//ValidBit tag[7]=0 if Valid(since addr are all lower than 0x20000)
reg[`InstBus] inst[`ICacheLines-1:0];

assign inst_fe=tag[inst_fpc[`IndexBits]]!=inst_fpc[`TagBits] & ~inst_ok;

always @(posedge clk) begin
	if(rdy==`True) begin
		if(rst==`True) begin
			pc_o<=`ZeroWord;
			taken_o<=`False;
		end else if(ex_b_flag_i==`True) begin
			pc_o<=ex_b_tar_i;
			taken_o<=`False;
		end else if(stall_state[0]==`False) begin
			if(taken_i==`True) begin
				pc_o<=P_b_tar_i;
				taken_o<=`True;
			end else begin
				pc_o<=pc_o+4;
				taken_o<=`False;			
			end
		end
	end
end

integer i;

always @(posedge clk) begin
	if(rdy==`True) begin
		if(rst==`True) begin
			for(i=0;i<`ICacheLines;i=i+1) begin
				tag[i][`ValidBit]<=`Invalid;
			end
			inst_fpc<=`ZeroWord;
		end else begin
			if(inst_ok) begin
				tag[inst_pc[`IndexBits]]<=inst_pc[`TagBits];
				inst[inst_pc[`IndexBits]]<=inst_i;
				inst_fpc<=pc_o+4;
			end else begin
				inst_fpc<=pc_o;
			end
		end
	end
end

always @(*) begin
	if(rdy==`False||rst==`True) begin
		inst_o=`ZeroWord;
		if_stall=`False;
	end else if(tag[pc_o[`IndexBits]]==pc_o[`TagBits]) begin
		if_stall=`False;
		inst_o=inst[pc_o[`IndexBits]];
	end else if(inst_ok&&inst_pc==pc_o) begin
		if_stall=`False;
		inst_o=inst_i;
	end else begin
		if_stall=`True;
		inst_o=`ZeroWord;
	end
end
endmodule