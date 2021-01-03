`define ZeroWord 32'h00000000
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0
`define Read 1'b0
`define Write 1'b1
`define False 1'b0
`define True 1'b1
`define Inst 1'b0
`define Data 1'b1

`define InstAddrBus 31:0
`define InstBus 31:0
`define RAMBus 7:0
`define MemBus 31:0
`define StallBus 3:0

`define NoStall 4'b0000
`define IfStall 4'b0001
`define IdStall 4'b0011
`define MemStall 4'b1111

`define RegAddrBus 4:0
`define RegBus 31:0
`define RegNum 32
`define RegAddrLen 5
`define NOPRegAddr 5'b00000

`define TagBus 7:0
`define TagBits 17:10
`define IndexBits 9:2
`define ICacheLines 256
`define ValidBit 7
`define Invalid 1'b1

`define PTagBus 8:0
`define PTagBits 17:9
`define PSize 128
`define PIndexBits 8:2
`define PValidBit 8

`define AluOpBus 4:0

`define LUI    7'b0110111
`define AUIPC  7'b0010111
`define JAL    7'b1101111
`define JALR   7'b1100111
`define BRANCH 7'b1100011
`define OPI    7'b0010011
`define OP     7'b0110011
`define LOAD   7'b0000011
`define STORE  7'b0100011

`define ADD  3'b000
`define SLT  3'b010
`define SLTU 3'b011
`define XOR  3'b100
`define OR   3'b110
`define AND  3'b111
`define SLL  3'b001
`define SRL  3'b101

`define BEQ   3'b000
`define BNE   3'b001
`define BLT   3'b100
`define BGE   3'b101
`define BLTU  3'b110
`define BGEU  3'b111

`define LB  3'b000
`define LH  3'b001
`define LW  3'b010
`define LBU 3'b100
`define LHU 3'b101

`define SB 3'b000
`define SH 3'b001
`define SW 3'b010

`define EX_NOP   5'h0
`define EX_ADD   5'h1
`define EX_SUB   5'h2
`define EX_SLT   5'h3
`define EX_SLTU  5'h4
`define EX_XOR   5'h5
`define EX_OR    5'h6
`define EX_AND   5'h7
`define EX_SLL   5'h8
`define EX_SRL   5'h9
`define EX_SRA   5'ha
`define EX_AUIPC 5'hb

`define EX_JAL   5'hc
`define EX_JALR  5'hd
`define EX_BEQ   5'he
`define EX_BNE   5'hf
`define EX_BLT   5'h10
`define EX_BGE   5'h11
`define EX_BLTU  5'h12
`define EX_BGEU  5'h13

`define EX_LB    5'h14
`define EX_LH    5'h15
`define EX_LW    5'h16
`define EX_LBU   5'h17
`define EX_LHU   5'h18

`define EX_SB    5'h19
`define EX_SH    5'h1a
`define EX_SW    5'h1b