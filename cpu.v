// RISCV32I CPU top module
// port modification allowed for debugging purposes
`include "macro.v"

module cpu(
	input  wire                 clk_in,			// system clock signal
	input  wire                 rst_in,			// reset signal
	input  wire					rdy_in,			// ready signal, pause cpu when low

	input  wire [ 7:0]          mem_din,		// data input bus
	output wire [ 7:0]          mem_dout,		// data output bus
	output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
	output wire                 mem_wr,			// write/read signal (1 for write)
	
	input  wire                 io_buffer_full, // 1 if uart buffer is full
	
	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read result will be returned in the next cycle. Write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

wire[`InstAddrBus] id_pc_i;
wire[`InstBus] id_inst_i;
wire[`InstAddrBus] id_pc_o;
wire[`AluOpBus] id_aluop_o;
wire[`RegBus] id_r1_o;
wire[`RegBus] id_r2_o;
wire id_w_req_o;
wire[`RegAddrBus] id_w_addr_o;
wire[`RegBus] id_offset_o;

wire[`RegBus] ex_offset_i;
wire[`InstAddrBus] ex_pc_i;
wire[`AluOpBus] ex_aluop_i;
wire[`AluOpBus] ex_aluop_o;
wire[`RegBus] ex_r1_i;
wire[`RegBus] ex_r2_i;
wire ex_w_req_i;
wire[`RegAddrBus] ex_w_addr_i;
wire ex_w_req_o;
wire[`RegAddrBus] ex_w_addr_o;
wire[`RegBus] ex_w_data_o;
wire ex_b_flag;
wire[`InstAddrBus] ex_b_tar;
wire ex_ld_flag;
wire[`RegBus] ex_mem_addr;

wire mem_w_req_i;
wire[`RegAddrBus] mem_w_addr_i;
wire[`RegBus] mem_w_data_i;
wire mem_w_req_o;
wire[`RegAddrBus] mem_w_addr_o;
wire[`RegBus] mem_w_data_o;
wire[`AluOpBus] mem_aluop_i;
wire[`RegBus] mem_mem_addr;

wire wb_w_req;
wire[`RegAddrBus] wb_w_addr;
wire[`RegBus] wb_w_data;

wire r1_req;
wire r2_req;
wire[`RegAddrBus] r1_addr;
wire[`RegAddrBus] r2_addr;
wire[`RegBus] r1_data;
wire[`RegBus] r2_data;

wire[`StallBus] stall_state;
wire if_stall;
wire id_stall;
wire mem_stall;

wire[`InstAddrBus] if_pc;
wire[`InstBus] if_inst;

wire[`InstBus] mem_ctrl_inst;
wire inst_fe;
wire[`InstAddrBus] inst_fpc;
wire inst_ok;
wire[`InstBus] inst_pc;

wire ram_r_req;
wire ram_w_req;
wire[`RegBus] ram_w_data;
wire[`RegBus] ram_r_data;
wire[1:0] ram_state;
wire[`RegBus] ram_addr;
wire ram_done;

wire is_branch;
wire[`InstAddrBus] b_tar;
wire ex_taken;
wire if_taken_i;
wire[`InstAddrBus] P_b_tar;
wire id_taken_i;
wire id_taken_o;
wire ex_taken_i;
wire ex_taken_o;
//wire[31:0] counter;
assign dbgreg_dout=if_pc;

predictor predictor0(
	.clk(clk_in),.rst(rst_in),.rdy(rdy_in),
	.if_pc(if_pc),.ex_pc(ex_pc_i),.is_branch(is_branch),
	.b_tar_i(b_tar),.taken_i(ex_taken_o),
	.taken_o(if_taken_i),.b_tar_o(P_b_tar)
);

regfile regfile0(
	.clk(clk_in),.rst(rst_in),.rdy(rdy_in),
	.w_req(wb_w_req),.w_addr(wb_w_addr),.w_data(wb_w_data),
	.r1_req(r1_req),.r1_addr(r1_addr),.r1_data(r1_data),
	.r2_req(r2_req),.r2_addr(r2_addr),.r2_data(r2_data)
);

IF if0(
	.clk(clk_in),.rst(rst_in),.rdy(rdy_in),
	.ex_b_flag_i(ex_b_flag),.ex_b_tar_i(ex_b_tar),
	.taken_i(if_taken_i),.P_b_tar_i(P_b_tar),
	.inst_i(mem_ctrl_inst),.inst_ok(inst_ok),.inst_pc(inst_pc),
	.stall_state(stall_state),
	.pc_o(if_pc),.inst_o(if_inst),.taken_o(id_taken_i),
	.inst_fe(inst_fe),.inst_fpc(inst_fpc),
	.if_stall(if_stall)
);

if_id if_id0(
	.clk(clk_in),.rst(rst_in),.rdy(rdy_in),
	.if_pc(if_pc),.if_inst(if_inst),
	.b_flag_i(ex_b_flag),.stall_state(stall_state),
	.id_pc(id_pc_i),.id_inst(id_inst_i)
);

id id0(
	.rst(rst_in),.rdy(rdy_in),
	.pc_i(id_pc_i),.inst_i(id_inst_i),.taken_i(id_taken_i),
	.r1_data_i(r1_data),.r2_data_i(r2_data),
	.ex_ld_flag(ex_ld_flag),.ex_w_req_i(ex_w_req_o),.ex_w_data_i(ex_w_data_o),.ex_w_addr_i(ex_w_addr_o),
	.mem_w_req_i(mem_w_req_o),.mem_w_data_i(mem_w_data_o),.mem_w_addr_i(mem_w_addr_o),
	.r1_req_o(r1_req),.r1_addr_o(r1_addr),.r1_o(id_r1_o),
	.r2_req_o(r2_req),.r2_addr_o(r2_addr),.r2_o(id_r2_o),
	.w_req_o(id_w_req_o),.w_addr_o(id_w_addr_o),.offset_o(id_offset_o),
	.pc_o(id_pc_o),.aluop_o(id_aluop_o),.taken_o(id_taken_o),
	.id_stall(id_stall)
);

id_ex id_ex0(
	.clk(clk_in),.rst(rst_in),.rdy(rdy_in),
	.id_aluop(id_aluop_o),.id_r1(id_r1_o),.id_r2(id_r2_o),
	.id_w_addr(id_w_addr_o),.id_w_req(id_w_req_o),
	.id_pc(id_pc_o),.id_offset(id_offset_o),.id_taken(id_taken_o),
	.b_flag_i(ex_b_flag),.stall_state(stall_state),
	.ex_aluop(ex_aluop_i),.ex_r1(ex_r1_i),.ex_r2(ex_r2_i),
	.ex_w_addr(ex_w_addr_i),.ex_w_req(ex_w_req_i),
	.ex_pc(ex_pc_i),.ex_offset(ex_offset_i),.ex_taken(ex_taken_i)
);

ex ex0(
 	.rst(rst_in),.rdy(rdy_in),//.counter(counter),
	.pc_i(ex_pc_i),.aluop_i(ex_aluop_i),.r1_i(ex_r1_i),.r2_i(ex_r2_i),.taken_i(ex_taken_i),
	.w_addr_i(ex_w_addr_i),.w_req_i(ex_w_req_i),.offset_i(ex_offset_i),
	.w_addr_o(ex_w_addr_o),.w_req_o(ex_w_req_o),.w_data_o(ex_w_data_o),
	.b_flag_o(ex_b_flag),.ex_b_tar_o(ex_b_tar),
	.b_tar_o(b_tar),.taken_o(ex_taken_o),.is_branch(is_branch),
	.aluop_o(ex_aluop_o),.mem_addr_o(ex_mem_addr),.is_ld(ex_ld_flag)
);

ex_mem ex_mem0(
	.clk(clk_in),.rst(rst_in),.rdy(rdy_in),
	.ex_w_addr(ex_w_addr_o),.ex_w_req(ex_w_req_o),.ex_w_data(ex_w_data_o),
	.ex_mem_addr(ex_mem_addr),.ex_aluop(ex_aluop_o),
	.stall_state(stall_state),
	.mem_w_addr(mem_w_addr_i),.mem_w_req(mem_w_req_i),.mem_w_data(mem_w_data_i),
	.mem_mem_addr(mem_mem_addr),.mem_aluop(mem_aluop_i)
);

mem mem0(
	.rst(rst_in),.rdy(rdy_in),
	.w_addr_i(mem_w_addr_i),.w_req_i(mem_w_req_i),.w_data_i(mem_w_data_i),
	.aluop_i(mem_aluop_i),.addr_i(mem_mem_addr),
	.ram_done_i(ram_done),.ram_r_data_i(ram_r_data),
	.w_addr_o(mem_w_addr_o),.w_req_o(mem_w_req_o),.w_data_o(mem_w_data_o),
	.ram_r_req_o(ram_r_req),.ram_w_req_o(ram_w_req),.ram_addr_o(ram_addr),
	.ram_w_data_o(ram_w_data),.ram_state(ram_state),
	.mem_stall(mem_stall)
);

mem_ctrl mem_ctrl0(
	.clk(clk_in),.rst(rst_in),.rdy(rdy_in),
	.ram_r_req_i(ram_r_req),.ram_w_req_i(ram_w_req),.ram_addr_i(ram_addr),
	.ram_data_i(ram_w_data),.type_i(ram_state),
	.inst_fe(inst_fe),.inst_fpc(inst_fpc),
	.mem_din(mem_din),.io_buffer_full(io_buffer_full),
	.ram_done_o(ram_done),.ram_data_o(ram_r_data),
	.inst_o(mem_ctrl_inst),.inst_ok(inst_ok),.inst_pc(inst_pc),
	.mem_dout(mem_dout),.mem_a(mem_a),.mem_wr(mem_wr)
);

mem_wb mem_wb0(
	.clk(clk_in),.rst(rst_in),.rdy(rdy_in),
	.mem_w_addr(mem_w_addr_o),.mem_w_req(mem_w_req_o),.mem_w_data(mem_w_data_o),
	.stall_state(stall_state),
	.wb_w_addr(wb_w_addr),.wb_w_req(wb_w_req),.wb_w_data(wb_w_data)
);

stall stall0(
	.if_stall(if_stall),.id_stall(id_stall),.mem_stall(mem_stall),
	.stall_state(stall_state)
);

endmodule