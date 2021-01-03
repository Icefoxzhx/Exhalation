module predictor(
	input wire clk,
	input wire rst,
	input wire rdy,

	input wire[`InstAddrBus] if_pc,

	input wire[`InstAddrBus] ex_pc,
	input wire is_branch,
	input wire[`InstAddrBus] b_tar_i,
	input wire taken_i,

	output reg  taken_o,
	output reg[`InstAddrBus] b_tar_o
);

reg[`PTagBus] tag[`PSize-1:0];
reg[`InstAddrBus] BTB[`PSize-1:0];
reg[1:0] BHT[`PSize-1:0];
integer i;

always @(posedge clk) begin
	if (rst) begin
		for(i=0;i<`PSize;i=i+1) begin
			tag[i][`PValidBit]<=`Invalid;
			BHT[i]<=2'b10;
		end
	end else if(rdy) begin
		if (is_branch) begin
			tag[ex_pc[`PIndexBits]]<=ex_pc[`PTagBits];
			BTB[ex_pc[`PIndexBits]]<=b_tar_i;
			if(taken_i&&BHT[ex_pc[`PIndexBits]]<2'h3) BHT[ex_pc[`PIndexBits]]<=BHT[ex_pc[`PIndexBits]]+1;
			if((~taken_i)&&BHT[ex_pc[`PIndexBits]]>2'h0) BHT[ex_pc[`PIndexBits]]<=BHT[ex_pc[`PIndexBits]]-1;
		end
	end
end

always @(*) begin
	if((~rdy)||rst) begin
		taken_o=`False;
		b_tar_o=`ZeroWord;
	end else if(tag[if_pc[`PIndexBits]]==if_pc[`PTagBits]&&BHT[if_pc[`PIndexBits]][1]==1'b1) begin
//	    $display("Predict taken!");
		taken_o=`True;
		b_tar_o=BTB[if_pc[`PIndexBits]];
	end else begin
		taken_o=`False;
		b_tar_o=`ZeroWord;
	end
end
endmodule