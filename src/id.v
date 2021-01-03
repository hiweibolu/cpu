`include "config.v"

module id(
	//in
		//from if_id
		input wire rst,
		input wire [`AddrLen - 1 : 0] pc,
		input wire [`InstLen - 1 : 0] inst,
		//from regfile
		input wire [`RegLen - 1 : 0] reg1_data_i,
		input wire [`RegLen - 1 : 0] reg2_data_i,
		
	//in by data forwarding
		input wire [`RegLen - 1 : 0] ex_mem_data_i,
		input wire [`RegAddrLen - 1 : 0] ex_mem_rd_i,
		input wire ex_mem_rd_enable,
		input wire [`RegLen - 1 : 0] mem_wb_data_i,
		input wire [`RegAddrLen - 1 : 0] mem_wb_rd_i,
		input wire mem_wb_rd_enable,
		
		input wire ex_load_enable,

    //out
		//to regfile
		output reg [`RegAddrLen - 1 : 0] reg1_addr_o,
		output reg reg1_read_enable,
		output reg [`RegAddrLen - 1 : 0] reg2_addr_o,
		output reg reg2_read_enable,
		
		//To next stage
		output reg [`RegLen - 1 : 0] reg1,
		output reg [`RegLen - 1 : 0] reg2,
		output reg [`RegLen - 1 : 0] Imm,
		output reg [`RegAddrLen - 1 : 0] rd,
		output reg rd_enable,
		output reg [`OpCodeLen - 1 : 0] aluop,
		output reg [`OpSelLen - 1 : 0] alusel,
		output reg [`AddrLen - 1 : 0] pc_o,
		
		output wire stall
);

wire [`OpLen - 1 : 0] opcode = inst[`OpLen - 1 : 0];
reg useImmInstead;
reg shametUsed;
reg reg1_stall;
reg reg2_stall;

assign stall = reg1_stall | reg2_stall;

// Get the address of reg1&2
always @ (*) begin
    if (rst == `Enable) begin
        reg1_addr_o = `ZeroReg;
        reg2_addr_o = `ZeroReg;
    end
    else begin
        reg1_addr_o = inst[19 : 15];
        reg2_addr_o = inst[24 : 20];
    end
end

always @(*) begin
	// Init the output
		reg1_read_enable = `Disable;
		reg2_read_enable = `Disable;
		
		Imm = `ZERO_WORD;
		rd = `ZeroReg; 
		rd_enable = `Disable;
		aluop = `EXE_NOP;
		alusel = `NOP_OP;
		pc_o = pc;
		
	// Default not use
		useImmInstead = `Disable;
		shametUsed = `Disable;
	
	// Fill the output
    case (opcode)
	
        `INTCOM_ORI: begin
			shametUsed = (inst[14:12] == 3'b101);
		
			reg1_read_enable = `Enable;
			
			Imm = shametUsed ? { 27'b0 ,inst[24:20] } : { {20{inst[31]}} ,inst[31:20] };
			useImmInstead = `Enable;
			
			rd = inst[11:7];
			rd_enable = `Enable;
			
			alusel = `LOGIC_OP;
			aluop = {1'b0 , shametUsed ? inst[30] : 1'b0, inst[14:12]};
			
        end
		
		`INTCOM_OR: begin
			reg1_read_enable = `Enable;
			reg2_read_enable = `Enable;
			
			rd = inst[11:7];
			rd_enable = `Enable;
			
			alusel = `LOGIC_OP;
			aluop = {1'b0, inst[30], inst[14:12]};
			
		end
		
		`INTCOM_SB: begin
			reg1_read_enable = `Enable;
			reg2_read_enable = `Enable;
			
			Imm = { {20{inst[31]}} ,inst[31:25] , inst[11:7]};
			
			alusel = `SAVE_OP;
			aluop = {2'b0, inst[14:12]} + `EXE_SB;
			
		end
		
		`INTCOM_LB: begin 
			reg1_read_enable = `Enable;
			
			rd = inst[11:7];
			rd_enable = `Enable;
			
			Imm = {{20{inst[31]}}, inst[31:20]};
			
			alusel = `LOAD_OP;
			aluop = {2'b0, inst[14:12]} + `EXE_LB;
			
		end
		
		`INTCOM_BEQ: begin
			reg1_read_enable = `Enable;
			reg2_read_enable = `Enable;
			
			Imm = { {20{inst[31]}}, inst[7], inst[30:25] , inst[11:8], 1'b0};
			
			alusel = `BRANCH_OP;
			case (inst[14:12])
			    3'b000: aluop = `EXE_BEQ;
			    3'b001: aluop = `EXE_BNE;
			    3'b100: aluop = `EXE_BLT;
			    3'b101: aluop = `EXE_BGE;
			    3'b110: aluop = `EXE_BLTU;
			    3'b111: aluop = `EXE_BGEU;
			endcase
			
		end
		
		`INTCOM_JALR: begin
			reg1_read_enable = `Enable;
			
			rd = inst[11:7];
			rd_enable = `Enable;
			
			Imm = { {20{inst[31]}}, inst[31:20]};
			
			aluop = `EXE_JALR;
			alusel = `LOGIC_OP;
		end
		
		`INTCOM_JAL: begin
			rd = inst[11:7];
			rd_enable = `Enable;
			
			Imm = { {12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
			
			aluop = `EXE_JAL;
			alusel = `LOGIC_OP;
		end
		
		`INTCOM_AUIPC: begin
			rd = inst[11:7];
			rd_enable = `Enable;
			
			Imm = { {12{inst[31]}}, inst[31:12]};
			
			aluop = `EXE_AUIPC;
            alusel = `LOGIC_OP;
		end
		
		`INTCOM_LUI: begin
			rd = inst[11:7];
			rd_enable = `Enable;
			
			Imm = { inst[31:12], 12'b0};
			
            alusel = `LOGIC_OP;
			aluop = `EXE_LUI;
		end

    endcase
end

//Get rs1
always @ (*) begin
	reg1_stall = `Disable;
    if (rst == `Enable) begin
        reg1 = `ZERO_WORD;
    end
    else if (reg1_read_enable == `Disable) begin
        reg1 = `ZERO_WORD;
    end
    else if (ex_load_enable == `Enable && reg1_addr_o == ex_mem_rd_i) begin
		reg1 = `ZERO_WORD;
		reg1_stall = `Enable;
	end
	else if (ex_mem_rd_enable == `Enable && reg1_addr_o == ex_mem_rd_i) begin
		reg1 = ex_mem_data_i;
	end
	else if (mem_wb_rd_enable == `Enable && reg1_addr_o == mem_wb_rd_i) begin
		reg1 = mem_wb_data_i;
	end
	else begin
        reg1 = reg1_data_i;
    end
end

//Get rs2
always @ (*) begin
	reg2_stall = `Disable;
    if (rst == `Enable) begin
        reg2 = `ZERO_WORD;
    end
    else if (reg2_read_enable == `Disable) begin
        if (useImmInstead == `Disable) reg2 = `ZERO_WORD;
        else reg2 = Imm;
    end
	else if (ex_load_enable == `Enable && reg2_addr_o == ex_mem_rd_i) begin
		reg2 = `ZERO_WORD;
		reg2_stall = `Enable;
	end
	else if (ex_mem_rd_enable == `Enable && reg2_addr_o == ex_mem_rd_i) begin
		reg2 = ex_mem_data_i;
	end
    else if (mem_wb_rd_enable == `Enable && reg2_addr_o == mem_wb_rd_i) begin
		reg2 = mem_wb_data_i;
	end
	else begin
        reg2 = reg2_data_i;
    end
end

endmodule
