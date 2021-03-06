module ex(
	input wire rst,
	input wire rdy,
	
	input wire[`InstAddrBus] pc_i,
	input wire taken_i,

	input wire[`AluOpBus] aluop_i,
	input wire[`RegBus] r1_i,
	input wire[`RegBus] r2_i,
	input wire[`RegAddrBus] w_addr_i,
	input wire w_req_i,
	input wire[`RegBus] offset_i,

	output reg[`RegAddrBus] w_addr_o,
	output reg w_req_o,
	output reg[`RegBus] w_data_o,

	output reg b_flag_o,
	output reg[`InstAddrBus] ex_b_tar_o,
	output wire[`InstAddrBus] b_tar_o,
	output reg taken_o,
	output reg is_branch,
    
	output reg[`AluOpBus] aluop_o,
	output reg[`RegBus] mem_addr_o,
	output reg is_ld
);

assign b_tar_o=pc_i+offset_i;
//reg[31:0] counter;//debug
    
always @(*) begin
	w_data_o=`ZeroWord;
	w_req_o=`False;
	w_addr_o=`NOPRegAddr;
	b_flag_o=`False;
	ex_b_tar_o=`ZeroWord;
	aluop_o=`EX_NOP;
	mem_addr_o=`ZeroWord;
	is_ld=`False;
	is_branch=`False;
	taken_o=`False;
	if(rdy==`True) begin
	   if(rst==`True) begin
	       //counter=`ZeroWord;
	   end
	   else begin
	       w_addr_o=w_addr_i;
           w_req_o=w_req_i;
           //counter=counter+1;
           case(aluop_i)
               `EX_OR: begin
                   w_data_o=r1_i|r2_i;
               end
               `EX_XOR: begin
                   w_data_o=r1_i^r2_i;
               end
               `EX_AND: begin
                   w_data_o=r1_i&r2_i;
               end
               `EX_SLL: begin
                   w_data_o=r1_i<<(r2_i[4:0]);
               end
               `EX_SRL: begin
                   w_data_o=r1_i>>(r2_i[4:0]);
               end
               `EX_SRA: begin
                   w_data_o=r1_i>>(r2_i[4:0])|({32{r1_i[31]}}<<(6'd32-{1'b0,r2_i[4:0]}));
               end
               `EX_ADD: begin
                   w_data_o=r1_i+r2_i;
               end
               `EX_SUB: begin
                   w_data_o=r1_i-r2_i;
               end
               `EX_SLT: begin
                   w_data_o=$signed(r1_i)<$signed(r2_i);
               end
               `EX_SLTU: begin
                   w_data_o=r1_i<r2_i;
               end
               `EX_AUIPC: begin
                   w_data_o=pc_i+offset_i;
               end
               `EX_SB,`EX_SH,`EX_SW: begin
                   mem_addr_o=r1_i+offset_i;
                   is_ld=`False;
                   aluop_o=aluop_i;
                   w_data_o=r2_i;
                  // counter=counter-1;
               end
               `EX_LB,`EX_LH,`EX_LW,`EX_LBU,`EX_LHU: begin
                   mem_addr_o=r1_i+offset_i;
                   is_ld=`True;
                   aluop_o=aluop_i;
               end
               `EX_JAL: begin
                   is_branch=`True;
                   ex_b_tar_o=pc_i+offset_i;
                   b_flag_o=~taken_i;
                   taken_o=`True;
                   w_data_o=pc_i+4;
               end
               `EX_JALR: begin
                   ex_b_tar_o=(r1_i+r2_i)&~1;
                   b_flag_o=`True;
                   w_data_o=pc_i+4;
               end
               `EX_BEQ: begin
                   is_branch=`True;
                   //counter=counter-1;
                   if(r1_i==r2_i) begin
                       ex_b_tar_o=pc_i+offset_i;
                       b_flag_o=~taken_i;
                       taken_o=`True;
                   end else begin
                       ex_b_tar_o=pc_i+4;
                       b_flag_o=taken_i;
                   end
               end
               `EX_BNE: begin
                   is_branch=`True;
                   //counter=counter-1;
                   if(r1_i!=r2_i) begin
                       ex_b_tar_o=pc_i+offset_i;
                       b_flag_o=~taken_i;
                       taken_o=`True;
                   end else begin
                       ex_b_tar_o=pc_i+4;
                       b_flag_o=taken_i;
                   end
               end
               `EX_BLT: begin
                   is_branch=`True;
                  // counter=counter-1;
                   if($signed(r1_i)<$signed(r2_i)) begin
                       ex_b_tar_o=pc_i+offset_i;
                       b_flag_o=~taken_i;
                       taken_o=`True;
                   end else begin
                       ex_b_tar_o=pc_i+4;
                       b_flag_o=taken_i;
                   end
               end
               `EX_BLTU: begin
                   is_branch=`True;
                  // counter=counter-1;
                   if(r1_i<r2_i) begin
                       ex_b_tar_o=pc_i+offset_i;
                       b_flag_o=~taken_i;
                       taken_o=`True;
                   end else begin
                       ex_b_tar_o=pc_i+4;
                       b_flag_o=taken_i;
                   end
               end
               `EX_BGE: begin
                   is_branch=`True;
                  // counter=counter-1;
                   if($signed(r1_i)>=$signed(r2_i)) begin
                       ex_b_tar_o=pc_i+offset_i;
                       b_flag_o=~taken_i;
                       taken_o=`True;
                   end else begin
                       ex_b_tar_o=pc_i+4;
                       b_flag_o=taken_i;
                   end
               end
               `EX_BGEU: begin
                   is_branch=`True;
                  // counter=counter-1;
                   if(r1_i>=r2_i) begin
                       ex_b_tar_o=pc_i+offset_i;
                       b_flag_o=~taken_i;
                       taken_o=`True;
                   end else begin
                       ex_b_tar_o=pc_i+4;
                       b_flag_o=taken_i;
                   end
               end
               default: begin
                   // counter=counter-1;
               end
           endcase
	   end
	end else begin
	   //counter=`ZeroWord;
	end
end
endmodule