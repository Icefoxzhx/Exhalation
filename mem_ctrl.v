module mem_ctrl(
	input wire clk,
	input wire rst,

	input wire ram_r_req_i,
	input wire ram_w_req_i,
	input wire[`MemBus] ram_addr_i,
	input wire[`RegBus] ram_data_i,
	input wire[1:0] type_i,

	input wire inst_fe,
	input wire[`InstAddrBus] inst_fpc,

	input wire[`RAMBus] mem_din,

	output reg ram_done_o,
	output reg[`RegBus] ram_data_o,

	output reg[`InstBus] inst_o,
	output reg inst_ok,
	output reg[`InstAddrBus] inst_pc,

	output reg[`RAMBus] mem_dout,
	output reg[`RAMAddrBus] mem_a,
	output reg mem_wr

);

reg[4:0] state;//4--I/D 3--R/W 2:0--stage
reg[`RAMAddrBus] addr0;
reg[`RegBus] data;

always @(posedge clk) begin
	if(rst==`RstEnable) begin
		state <= 5'b0;
		mem_dout <= 8'b0;
		mem_a <=`ZeroWord;
		mem_wr <= `Read;
		inst_o<=`ZeroWord;
		inst_ok<=`False;
		inst_pc<=`ZeroWord;
		ram_done_o<=`False;
		ram_data_o<=`ZeroWord;
		addr0<=`ZeroWord;
		data<=`ZeroWord;
	end else begin
		inst_ok <=`False;
		if(state==5'b0) begin
			if(ram_r_req_i==`True) begin
				ram_done_o<=`False;
				inst_ok<=`False;
				addr0<=ram_addr_i;
				mem_wr<=`Read;
				case(type_i)
					2'b11: begin
						state<=5'b11100;
						mem_a<=ram_addr_i+3;
					end
					2'b01: begin
						state<=5'b11010;
						mem_a<=ram_addr_i+1;
					end
					2'b00: begin
						state<=5'b11001;
						mem_a<=ram_addr_i;
					end
				endcase
			end else if(ram_w_req_i==`True) begin
				ram_done_o<=`False;
				inst_ok<=`False;
				addr0<=ram_addr_i;
				data<=ram_data_i;
				mem_wr<=`Write;
				case(type_i)
					2'b11: begin
						state<=5'b10100;
						mem_a<=ram_addr_i+3;
						mem_dout<=ram_data_i[31:24];
					end
					2'b01: begin
						state<=5'b10010;
						mem_a<=ram_addr_i+1;
						mem_dout<=ram_data_i[15:8];
					end
					2'b00: begin
						state<=5'b0;
						mem_a<=ram_addr_i;
						mem_dout<=ram_data_i[7:0];
						ram_done_o<=`True;
					end
				endcase
			end else if(inst_fe) begin
				ram_done_o<=`False;
				inst_ok<=`False;
				addr0<=inst_fpc;
				mem_wr<=`Read;
				state<=5'b01100;
				mem_a<=inst_fpc+3;
			end else begin
				ram_done_o<=`False;
				inst_ok<=`False;
				state<=5'b0;
				mem_a<=`ZeroWord;
				mem_wr<=`Read;
			end
		end else if(state[3]!=`Read) begin//Read
			ram_done_o<=`False;
			inst_ok<=`False;
			if(state[4]==`Inst&&inst_fe&&inst_fpc!=addr0) begin//branch restart fetch
				addr0<=inst_fpc;
				mem_wr<=`Read;
				state<=5'b01100;
				mem_a<=inst_fpc+3;
			end else begin
				case(state[2:0])
					3'b100: begin						
						mem_a<=addr0+2;
						mem_wr<=`Read;
						state[2:0]<=3'b011;
					end
					3'b011: begin
						data[31:24]<=mem_din;						
						mem_a<=addr0+1;
						mem_wr<=`Read;
						state[2:0]<=3'b010;
					end
					3'b010: begin
						data[23:16]<=mem_din;						
						mem_a<=addr0;
						mem_wr<=`Read;
						state[2:0]<=3'b001;
					end
					3'b001: begin
						data[15:8]<=mem_din;
						state[2:0]<=3'b000;
					end
					3'b000: begin
						data[7:0]<=mem_din;
						if(state[4]==`Inst) begin
							inst_ok<=`True;
							inst_o<={data[31:8],mem_din};
							inst_pc<=addr0;
						end else begin
							ram_done_o<=`True;
							ram_data_o<={data[31:8],mem_din};
						end
						state<=5'b000;
					end
				endcase
			end
		end else begin//write
			ram_done_o<=`False;
			inst_ok<=`False;
			case(state[2:0])
				3'b100: begin
					mem_dout<=data[23:16];
					mem_a<=addr0+2;
					mem_wr<=`Write;
					state[2:0]<=3'b011;
				end
				3'b011: begin
					mem_dout<=data[15:8];
					mem_a<=addr0+1;
					mem_wr<=`Write;
					state[2:0]<=3'b010;
				end
				3'b010: begin
					mem_dout<=data[7:0];
					mem_a<=addr0;
					mem_wr<=`Write;
					state<=5'b0;
					ram_done_o=`True;
				end
			endcase
		end
	end
end
endmodule