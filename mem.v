module mem(
	input wire rst,
	input wire rdy,
	
	input wire[`RegAddrBus] w_addr_i,
	input wire w_req_i,
	input wire[`RegBus] w_data_i,

	input wire[`AluOpBus] aluop_i,
	input wire[`MemBus] addr_i,

	input wire ram_done_i,
	input wire[`RegBus] ram_r_data_i,

	output reg[`RegAddrBus] w_addr_o,
	output reg w_req_o,
	output reg[`RegBus] w_data_o,

	output reg ram_r_req_o,
	output reg ram_w_req_o,
	output reg[`RegBus] ram_addr_o,
	output reg[`RegBus] ram_w_data_o,
	output reg[1:0] ram_state,

	output reg mem_stall
);

always @(*) begin
	if(rdy==`False||rst==`True) begin
		w_addr_o=`NOPRegAddr;
		w_req_o=`False;
		w_data_o=`ZeroWord;
		ram_r_req_o=`False;
		ram_w_req_o=`False;
		ram_w_data_o=`ZeroWord;
		ram_addr_o=`ZeroWord;
		ram_state=2'h0;
		mem_stall=`False;
	end else begin
		w_addr_o=w_addr_i;
		w_req_o=w_req_i;
		ram_r_req_o=`False;
		ram_w_req_o=`False;
		mem_stall=`False;
		w_data_o=w_data_i;
		ram_addr_o=`ZeroWord;
		ram_w_data_o=`ZeroWord;
		ram_state=2'b0;
		case(aluop_i)
			`EX_LB:begin
				w_data_o={{24{ram_r_data_i[7]}},ram_r_data_i[7:0]};
				if(!ram_done_i) begin
					ram_r_req_o=`True;
					mem_stall=`True;
				end
				ram_addr_o=addr_i;
				ram_state=2'b0;
			end
			`EX_LBU:begin
				w_data_o={24'b0,ram_r_data_i[7:0]};
				if(!ram_done_i) begin
					ram_r_req_o=`True;
					mem_stall=`True;
				end
				ram_addr_o=addr_i;
				ram_state=2'b0;
			end
			`EX_LH:begin
				w_data_o={{16{ram_r_data_i[15]}},ram_r_data_i[15:0]};
				if(!ram_done_i) begin
					ram_r_req_o=`True;
					mem_stall=`True;
				end
				ram_addr_o=addr_i;
				ram_state=2'b01;
			end
			`EX_LHU:begin
				w_data_o={16'b0,ram_r_data_i[15:0]};
				if(!ram_done_i) begin
					ram_r_req_o=`True;
					mem_stall=`True;
				end
				ram_addr_o=addr_i;
				ram_state=2'b01;
			end
			`EX_LW:begin
				w_data_o=ram_r_data_i;
				if(!ram_done_i) begin
					ram_r_req_o=`True;
					mem_stall=`True;
				end
				ram_addr_o=addr_i;
				ram_state=2'b11;
			end
			`EX_SB:begin
				if(!ram_done_i) begin
					ram_w_req_o=`True;
					mem_stall=`True;
				end
				ram_w_data_o=w_data_i;
				ram_addr_o=addr_i;
				ram_state=2'b00;
			end
			`EX_SH:begin
				if(!ram_done_i) begin
					ram_w_req_o=`True;
					mem_stall=`True;
				end
				ram_w_data_o=w_data_i;
				ram_addr_o=addr_i;
				ram_state=2'b01;
			end
			`EX_SW:begin
				if(!ram_done_i) begin
					ram_w_req_o=`True;
					mem_stall=`True;
				end
				ram_w_data_o=w_data_i;
				ram_addr_o=addr_i;
				ram_state=2'b11;
			end
		endcase
	end
end
endmodule