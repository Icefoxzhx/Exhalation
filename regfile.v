module regfile(
	input wire clk,
	input wire rst,

	input wire w_req,
	input wire[`RegAddrBus] w_addr,
	input wire[`RegBus] w_data,

	input wire r1_req,
	input wire[`RegAddrBus] r1_addr,
	output reg[`RegBus] r1_data,

	input wire r2_req,
	input wire[`RegAddrBus] r2_addr,
	output reg[`RegBus] r2_data
);

reg[`RegBus] regs[0:`RegNum-1];
integer i;

always @(posedge clk) begin
	if(rst==`RstEnable) begin
		for(i=0;i<`RegNum;i=i+1)
			regs[i]<=`ZeroWord;
	end else begin
		if((w_req==`True)&&(w_addr!=`RegAddrLen'h0)) begin
			regs[w_addr]<=w_data;
		end
	end
end

always @(*) begin
	r1_data=`ZeroWord;
	if((rst!=`RstEnable)&&(r1_req==`True) ) begin
		if(r1_addr==`RegAddrLen'h0)
			r1_data=`ZeroWord;
		else if((r1_addr==w_addr)&&(w_req==`True))
			r1_data=w_data;//forwarding
		else
			r1_data=regs[r1_addr];
	end
end

always @(*) begin
	r2_data=`ZeroWord;
	if((rst!=`RstEnable)&&(r2_req==`True) ) begin
		if(r2_addr==`RegAddrLen'h0)
			r2_data=`ZeroWord;
		else if((r2_addr==w_addr)&&(w_req==`True))
			r2_data=w_data;//forwarding
		else
			r2_data=regs[r2_addr];
	end
end

endmodule