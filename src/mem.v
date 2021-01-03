`include "config.v"

module mem(
    input rst,
	
    input wire [`RegLen - 1 : 0] rd_data_i,
    input wire [`RegAddrLen - 1 : 0] rd_addr_i,
    input wire rd_enable_i,
	input wire [`OpCodeLen - 1 : 0] aluop,
	input wire [`RegLen - 1 : 0] mem_addr_i,

	input wire ram_done,
	input wire [`RegLen - 1 : 0] ram_data,
	
	output reg ram_read_enable,
	output reg ram_write_enable,
	output reg [`RegLen - 1 : 0] ram_addr_o,
	output reg [`RegLen - 1 : 0] ram_data_o,
	output reg [1 : 0] ram_offset,
	
	output reg stall,
	
    output reg [`RegLen - 1 : 0] rd_data_o,
    output reg [`RegAddrLen - 1 : 0] rd_addr_o,
    output reg rd_enable_o
);

always @ (*) begin

	ram_read_enable = `Disable;
	ram_write_enable = `Disable;
	ram_addr_o = `ZERO_WORD;
	ram_data_o = `ZERO_WORD;
	ram_offset = 2'b00;
	
	stall = `Disable;
	rd_data_o = `ZERO_WORD;
	rd_addr_o = `ZeroReg;
	rd_enable_o = `Disable;
	
    if (rst == `Disable) begin
        rd_data_o = rd_data_i;
        rd_addr_o = rd_addr_i;
        rd_enable_o = rd_enable_i;
		case (aluop)
			`EXE_SB,
			`EXE_SH,
			`EXE_SW: begin
				ram_write_enable = `Enable;
				ram_addr_o = mem_addr_i;
				ram_data_o = rd_data_i;
				case (aluop)
					`EXE_SB:
						ram_offset = 2'b00;
					`EXE_SH:
						ram_offset = 2'b01;
					`EXE_SW:
						ram_offset = 2'b11;
				endcase
				stall = ~ram_done;
			end
			`EXE_LB,
			`EXE_LH,
			`EXE_LW,
			`EXE_LBU,
			`EXE_LHU: begin
				ram_read_enable = `Enable;
				ram_addr_o = mem_addr_i;
				case (aluop)
					`EXE_LB: begin
						ram_offset = 2'b00;
						rd_data_o = { {24 {ram_data[7]}}, ram_data[7 : 0]};
					end
					`EXE_LH: begin
						ram_offset = 2'b01;
						rd_data_o = { {16 {ram_data[7]}}, ram_data[15 : 0]};
					end
					`EXE_LW: begin
						ram_offset = 2'b11;
						rd_data_o = ram_data;
					end
					`EXE_LBU: begin
						ram_offset = 2'b00;
						rd_data_o = {24'b0, ram_data[7 : 0]};
                    end
					`EXE_LHU: begin
						ram_offset = 2'b01;
						rd_data_o = {16'b0, ram_data[15 : 0]};
                    end
				endcase
				stall = ~ram_done;
			end
		endcase
    end
end

endmodule
