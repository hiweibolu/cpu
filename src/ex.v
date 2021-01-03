`include "config.v"

module ex(
    input wire rst,

    input wire [`RegLen - 1 : 0] reg1,
    input wire [`RegLen - 1 : 0] reg2,
    input wire [`RegLen - 1 : 0] Imm,
    input wire [`RegAddrLen - 1 : 0] rd,
    input wire rd_enable,
    input wire [`OpCodeLen - 1 : 0] aluop,
    input wire [`OpSelLen - 1 : 0] alusel,
	input wire [`AddrLen - 1 : 0] pc,
	input wire jump_i,

	output reg [`AddrLen - 1 : 0] jump_target,
	output reg jump_mistake,
	output reg predictor_jump,
	output reg predictor_jump_plus,
    output reg [`AddrLen - 1 : 0] predictor_jump_target,
	output reg [`OpCodeLen - 1 : 0] aluop_o,
	output reg [`AddrLen - 1 : 0] mem_addr_o,
	output reg load_enable_o,
    output reg [`RegLen - 1 : 0] rd_data_o,
    output reg [`RegAddrLen - 1 : 0] rd_addr,
    output reg rd_enable_o
);

reg [`RegLen - 1 : 0] res;
reg branch;

    //Do the calculation
always @ (*) begin
	res = `ZERO_WORD;
	
	mem_addr_o = `ZERO_WORD;
	load_enable_o = `Disable;
	
	jump_target = `ZERO_WORD;
	jump_mistake = `Disable;
	predictor_jump = `Disable;
	predictor_jump_plus = `Disable;
	predictor_jump_target = `ZERO_WORD;
	
	if (rst == `Disable) begin
		
		case (aluop)
			`EXE_ADD:
				res = reg1 + reg2; 
			`EXE_SUB:
				res = reg1 - reg2; 
			`EXE_SLT:
				res = $signed(reg1) < $signed(reg2);
			`EXE_SLTU: 
				res = reg1 < reg2;
			`EXE_AUIPC:
				res = pc + Imm;
			`EXE_LUI:
				res = Imm;
			`EXE_XOR:
				res = reg1 ^ reg2; 
			`EXE_OR:
				res = reg1 | reg2; 
			`EXE_AND:
				res = reg1 & reg2; 
			`EXE_SLL:
				res = reg1 << reg2[4:0]; 
			`EXE_SRL:
				res = reg1 >> reg2[4:0]; 
			`EXE_SRA:
				res = $signed(reg1) >>> reg2[4:0];
			`EXE_SB,
			`EXE_SH,
			`EXE_SW: 
                mem_addr_o = reg1 + Imm;
			`EXE_LW,
			`EXE_LH,
			`EXE_LB,
			`EXE_LHU,
			`EXE_LBU: begin
                mem_addr_o = reg1 + Imm;
                load_enable_o = `Enable;
            end
			`EXE_JAL: begin
				jump_target = pc + Imm;
				jump_mistake = ~jump_i;
				predictor_jump = `Enable;
				predictor_jump_plus = `Enable;
                predictor_jump_target = pc + Imm;
				res = pc + 4;
			end
			`EXE_JALR: begin
				jump_target = reg1 + Imm;
				jump_target = {jump_target[31 : 1], 1'b0};
				jump_mistake = `Enable;
				res = pc + 4;
			end
			`EXE_BEQ,
			`EXE_BNE,
			`EXE_BLT,
			`EXE_BGE,
			`EXE_BLTU,
			`EXE_BGEU: begin
				predictor_jump = `Enable;
                predictor_jump_target = pc + Imm;
				branch = `Disable;
				case (aluop)
					`EXE_BEQ:
						branch = reg1 == reg2;
					`EXE_BNE:
						branch = reg1 != reg2;
					`EXE_BLT:
						branch = $signed(reg1) < $signed(reg2);
					`EXE_BGE:
						branch = $signed(reg1) >= $signed(reg2); // shit the >=
					`EXE_BLTU:
						branch = reg1 < reg2;
					`EXE_BGEU:
						branch = reg1 >= reg2; // shit the >=
				endcase 
				if (branch == `Enable) begin
					jump_target = pc + Imm;
					jump_mistake = ~jump_i;
					predictor_jump_plus = `Enable;
				end
				else begin
					jump_target = pc + 4;
					jump_mistake = jump_i;
				end
			end
			
		endcase
	end
end
	//Determine the output
always @ (*) begin
	rd_addr = `ZeroReg;
	rd_enable_o = `Disable;
	rd_data_o = `ZERO_WORD;
	aluop_o = `EXE_NOP;
	if (rst == `Disable) begin
		rd_addr = rd;
		rd_enable_o = rd_enable;
		aluop_o = aluop;
		case (alusel)
			`LOGIC_OP:
				rd_data_o = res;
			`SAVE_OP:
				rd_data_o = reg2;
		endcase
	end
end

endmodule
