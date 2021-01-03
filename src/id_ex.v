`include "config.v"

module id_ex(
    input wire clk,
    input wire rst,
    input wire rdy,
    input wire [`RegLen - 1 : 0] id_reg1,
    input wire [`RegLen - 1 : 0] id_reg2,
    input wire [`RegLen - 1 : 0] id_Imm,
    input wire [`RegAddrLen - 1 : 0] id_rd,
    input wire id_rd_enable,
    input wire [`OpCodeLen - 1 : 0] id_aluop,
    input wire [`OpSelLen - 1 : 0] id_alusel,
	input wire [`AddrLen - 1 : 0] id_pc,
	
	input wire [`StallLen - 1 : 0] stall,
	input wire jump_i,
	input wire jump_mistake,

    output reg [`RegLen - 1 : 0] ex_reg1,
    output reg [`RegLen - 1 : 0] ex_reg2,
    output reg [`RegLen - 1 : 0] ex_Imm,
    output reg [`RegAddrLen - 1 : 0] ex_rd,
    output reg ex_rd_enable,
    output reg [`OpCodeLen - 1 : 0] ex_aluop,
    output reg [`OpSelLen - 1 : 0] ex_alusel,
	output reg [`AddrLen - 1 : 0] ex_pc,
	output reg jump_o
);

always @ (posedge clk) begin
    if (rst == `Enable) begin
        //TODO: ASSIGN ALL OUTPUT WITH NULL EQUIVALENT
        ex_reg1 <= `ZERO_WORD;
        ex_reg2 <= `ZERO_WORD;
        ex_Imm <= `ZERO_WORD;
        ex_rd <= `ZeroReg;
        ex_rd_enable <= `Disable;
        ex_aluop <= `EXE_NOP;
        ex_alusel <= `NOP_OP;
		ex_pc <= `ZERO_WORD;
		jump_o <= `Disable;
    end
    else if (rdy == `Disable) begin
    end
	else if (stall[2] == `Enable) begin
	end
	else if (jump_mistake == `Enable) begin
        ex_reg1 <= `ZERO_WORD;
        ex_reg2 <= `ZERO_WORD;
        ex_Imm <= `ZERO_WORD;
        ex_rd <= `ZeroReg;
        ex_rd_enable <= `Disable;
        ex_aluop <= `EXE_NOP;
        ex_alusel <= `NOP_OP;
		ex_pc <= `ZERO_WORD;
		jump_o <= `Disable;
	end
	else if (stall[1] == `Enable) begin
        ex_reg1 <= `ZERO_WORD;
        ex_reg2 <= `ZERO_WORD;
        ex_Imm <= `ZERO_WORD;
        ex_rd <= `ZeroReg;
        ex_rd_enable <= `Disable;
        ex_aluop <= `EXE_NOP;
        ex_alusel <= `NOP_OP;
        ex_pc <= `ZERO_WORD;
        jump_o <= `Disable;
	end
    else begin
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_Imm <= id_Imm;
        ex_rd <= id_rd;
        ex_rd_enable <= id_rd_enable;
        ex_aluop <= id_aluop;
        ex_alusel <= id_alusel;
        ex_pc <= id_pc;
        jump_o <= jump_i;
    end
end

endmodule
