`ifndef hasDefined
`define hasDefined

`define ZERO_WORD 32'h00000000
`define ZeroReg 5'b00000
`define ZERO_BYTE 8'h00

`define InstLen 32
`define AddrLen 32
`define RegAddrLen 5
`define RegLen 32
`define RegNum 32
`define ByteLen 8

`define Enable 1'b1
`define Disable 1'b0

`define RAM_SIZE 100
`define RAM_SIZELOG2 17

//OPCODE
`define OpLen 7
`define INTCOM_ORI 7'b0010011
`define INTCOM_OR 7'b0110011
`define INTCOM_SB 7'b0100011
`define INTCOM_LB 7'b0000011
`define INTCOM_BEQ 7'b1100011
`define INTCOM_JALR 7'b1100111
`define INTCOM_JAL 7'b1101111
`define INTCOM_AUIPC 7'b0010111
`define INTCOM_LUI 7'b0110111

//AluOP
`define OpCodeLen 5
`define EXE_ADD 5'b000
`define EXE_SLT 5'b010
`define EXE_SLTU 5'b011
`define EXE_XOR 5'b100
`define EXE_OR 5'b110
`define EXE_AND 5'b111
`define EXE_SLL 5'b001
`define EXE_SRL 5'b101
`define EXE_SRA 5'b1101
`define EXE_SUB 5'b1000
`define EXE_NOP 5'b1001
`define EXE_JAL 5'b1010
`define EXE_AUIPC 5'b1011
`define EXE_JALR 5'b1100
`define EXE_LUI 5'b1110
`define EXE_SB 5'b1111
`define EXE_SH 5'b10000
`define EXE_SW 5'b10001
`define EXE_LB 5'b10011
`define EXE_LH 5'b10100
`define EXE_LW 5'b10101
`define EXE_LBU 5'b10111
`define EXE_LHU 5'b11000
`define EXE_BEQ 5'b11001
`define EXE_BNE 5'b11010
`define EXE_BLT 5'b11011
`define EXE_BGE 5'b11100
`define EXE_BLTU 5'b11101
`define EXE_BGEU 5'b11110

//AluSelect
`define OpSelLen 3
`define BRANCH_OP 3'b100
`define LOAD_OP 3'b011
`define SAVE_OP 3'b010
`define LOGIC_OP 3'b001
`define NOP_OP 3'b000

`define StallLen 3
`define NoStall 3'b000

`define IndexBus 9:2
`define IndexLen 256
`define TagBus 17:10
`define TagLen 8

`endif
