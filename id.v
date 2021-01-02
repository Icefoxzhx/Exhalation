module id(
	input wire rst,
	input wire rdy,
	
	input wire[`InstAddrBus] pc_i,
	input wire[`InstBus] inst_i,

	input wire[`RegBus] r1_data_i,
	input wire[`RegBus] r2_data_i,

	input wire ex_ld_flag,
	input wire ex_w_req_i,
	input wire[`RegBus] ex_w_data_i,
	input wire[`RegAddrBus] ex_w_addr_i,

	input wire mem_w_req_i,
	input wire[`RegBus] mem_w_data_i,
	input wire[`RegAddrBus] mem_w_addr_i,

	output reg r1_req_o,
	output reg r2_req_o,
	output reg[`RegAddrBus] r1_addr_o,
	output reg[`RegAddrBus] r2_addr_o,

	output reg[`InstAddrBus] pc_o,
	output reg[`AluOpBus] aluop_o,
	output reg[`RegBus] r1_o,
	output reg[`RegBus] r2_o,
	output reg[`RegAddrBus] w_addr_o,
	output reg w_req_o,
	output reg[`RegBus] offset_o,

	output wire id_stall
);

wire[6:0] opcode=inst_i[6:0];
wire[4:0] rd=inst_i[11:7];
wire[2:0] func3=inst_i[14:12];
wire[4:0] rs1=inst_i[19:15];
wire[4:0] rs2=inst_i[24:20];
wire[6:0] func7=inst_i[31:25];
wire[11:0] I_imm=inst_i[31:20];
wire[11:0] S_imm={inst_i[31:25], inst_i[11:7]};
wire[11:0] B_imm={inst_i[31], inst_i[7], inst_i[30:25], inst_i[11:8]};
wire[19:0] U_imm=inst_i[31:12];
wire[19:0] J_imm={inst_i[31], inst_i[19:12], inst_i[20], inst_i[30:21]};
reg r1_stall;
reg r2_stall;

always @(*) begin
	aluop_o=`EX_NOP;
	w_req_o=`False;
	r1_req_o=`False;
	r2_req_o=`False;
	w_addr_o=rd;
	r1_addr_o=rs1;
	r2_addr_o=rs2;
	pc_o=pc_i;
	offset_o=`ZeroWord;
	if(rdy==`True&&rst==`False) begin
		case(opcode)
			`OPI:begin
				w_req_o=`True;
				r1_req_o=`True;
				r2_req_o=`False;
				case(func3)
					`ADD:begin
						aluop_o=`EX_ADD;
						offset_o={{20{I_imm[11]}},I_imm};
					end
					`SLT:begin
						aluop_o=`EX_SLT;
						offset_o={{20{I_imm[11]}},I_imm};
					end
					`SLTU:begin
						aluop_o=`EX_SLTU;
						offset_o={{20{I_imm[11]}},I_imm};
					end
					`XOR:begin
						aluop_o=`EX_XOR;
						offset_o={{20{I_imm[11]}},I_imm};
					end
					`OR:begin
						aluop_o=`EX_OR;
						offset_o={{20{I_imm[11]}},I_imm};
					end
					`AND:begin
						aluop_o=`EX_AND;
						offset_o={{20{I_imm[11]}},I_imm};
					end
					`SLL:begin
						aluop_o=`EX_SLL;
						offset_o={27'h0,I_imm[4:0]};
					end
					`SRL:begin
						case(func7)
							7'b0000000:begin
								aluop_o=`EX_SRL;							
								offset_o={27'h0,I_imm[4:0]};
							end
							7'b0100000:begin
								aluop_o=`EX_SRA;
								offset_o={27'h0,I_imm[4:0]};
							end
						endcase
					end
				endcase
			end
			`OP:begin
				w_req_o=`True;
				r1_req_o=`True;
				r2_req_o=`True;
				offset_o=`ZeroWord;
				case(func3)
					`ADD:begin
						case(func7)
							7'b0000000:begin//ADD
								aluop_o=`EX_ADD;					
							end
							7'b0100000:begin
								aluop_o=`EX_SUB;
							end
						endcase				
					end
					`SLT:begin
						aluop_o=`EX_SLT;						
					end
					`SLTU:begin
						aluop_o=`EX_SLTU;
					end
					`XOR:begin
						aluop_o=`EX_XOR;
					end
					`OR:begin
						aluop_o=`EX_OR;
					end
					`AND:begin
						aluop_o=`EX_AND;
					end
					`SLL:begin
						aluop_o=`EX_SLL;					
					end
					`SRL:begin
						case(func7)
							7'b0000000:begin
								aluop_o=`EX_SRL;								
							end
							7'b0100000:begin
								aluop_o=`EX_SRA;
							end
						endcase
					end
				endcase
			end
			`LOAD:begin
				w_req_o=`True;
				r1_req_o=`True;
				r2_req_o=`False;
				offset_o={{20{I_imm[11]}},I_imm};
				case(func3)
					`LB:begin
						aluop_o=`EX_LB;
					end
					`LH:begin
						aluop_o=`EX_LH;
					end
					`LW:begin
						aluop_o=`EX_LW;
					end
					`LBU:begin
						aluop_o=`EX_LBU;
					end
					`LHU:begin
						aluop_o=`EX_LHU;
					end
				endcase
			end
			`STORE:begin
				w_req_o=`False;
				r1_req_o=`True;
				r2_req_o=`True;
				offset_o={{20{S_imm[11]}},S_imm};
				case(func3)
					`SB:begin
						aluop_o=`EX_SB;
					end
					`SH:begin
						aluop_o=`EX_SH;
					end
					`SW:begin
						aluop_o=`EX_SW;
					end
				endcase
			end
			`BRANCH:begin
				w_req_o=`False;
				r1_req_o=`True;
				r2_req_o=`True;
				offset_o={{19{B_imm[11]}},B_imm,1'b0};
				case(func3)
					`BEQ:begin
						aluop_o=`EX_BEQ;
					end
					`BNE:begin
						aluop_o=`EX_BNE;
					end
					`BLT:begin
						aluop_o=`EX_BLT;
					end
					`BGE:begin
						aluop_o=`EX_BGE;
					end
					`BLTU:begin
						aluop_o=`EX_BLTU;
					end
					`BGEU:begin
						aluop_o=`EX_BGEU;
					end
				endcase
			end
			`JAL:begin
				aluop_o=`EX_JAL;
				w_req_o=`True;
				r1_req_o=`False;
				r2_req_o=`False;
				offset_o={{11{J_imm[19]}},J_imm,1'h0};
			end
			`JALR:begin
				aluop_o=`EX_JALR;
				w_req_o=`True;
				r1_req_o=`True;
				r2_req_o=`False;
				offset_o={{20{I_imm[11]}},I_imm};
			end
			`LUI:begin
				aluop_o=`EX_OR;//???NOP?
				w_req_o=`True;
				r1_req_o=`False;
				r2_req_o=`False;
				offset_o={U_imm,12'h0};
			end
			`AUIPC:begin
				aluop_o=`EX_AUIPC;
				w_req_o=`True;
				r1_req_o=`False;
				r2_req_o=`False;
				offset_o={U_imm,12'h0};
			end
		endcase
	end
end

always @(*) begin
	r1_stall=`False;
	r1_o=`ZeroWord;
	if(rdy==`True&&rst==`False) begin
		if(r1_req_o==`True) begin
			if(ex_ld_flag==`True && ex_w_addr_i==r1_addr_o) begin
				r1_stall=`True;
			end else if(ex_w_req_i==`True && ex_w_addr_i==r1_addr_o) begin
				r1_o=ex_w_data_i;
			end else if(mem_w_req_i==`True && mem_w_addr_i==r1_addr_o) begin
				r1_o=mem_w_data_i;
			end else begin
				r1_o=r1_data_i;
			end
		end else begin
			r1_o=offset_o;
		end
	end
end

always @(*) begin
	r2_stall=`False;
	r2_o=`ZeroWord;
	if(rdy==`True&&rst==`False) begin
		if(r2_req_o==`True) begin
			if(ex_ld_flag==`True && ex_w_addr_i==r2_addr_o) begin
				r2_stall=`True;
			end else if(ex_w_req_i==`True && ex_w_addr_i==r2_addr_o) begin
				r2_o=ex_w_data_i;
			end else if(mem_w_req_i==`True && mem_w_addr_i==r2_addr_o) begin
				r2_o=mem_w_data_i;
			end else begin
				r2_o=r2_data_i;
			end
		end else begin
			r2_o=offset_o;
		end
	end
end

assign id_stall=r1_stall|r2_stall;
endmodule