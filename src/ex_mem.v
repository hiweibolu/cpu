`include "config.v"

module ex_mem(
    input wire clk,
    input wire rst,
    input wire rdy,
	
    input wire [`RegLen - 1 : 0] ex_rd_data,
    input wire [`RegAddrLen - 1 : 0] ex_rd_addr,
    input wire ex_rd_enable,
	input wire [`OpCodeLen - 1 : 0] aluop_i,
	input wire [`RegLen - 1 : 0] mem_addr_i,
	
	input wire [`StallLen - 1 : 0] stall,

	output reg [`OpCodeLen - 1 : 0] aluop_o,
	output reg [`RegLen - 1 : 0] mem_addr_o,
    output reg [`RegLen - 1 : 0] mem_rd_data,
    output reg [`RegAddrLen - 1 : 0] mem_rd_addr,
    output reg mem_rd_enable
);

always @ (posedge clk) begin
    if (rst == `Enable) begin
        //TODO: Reset
        mem_rd_data <= `ZERO_WORD;
        mem_rd_addr <= `ZERO_WORD;
        mem_rd_enable <= `Disable;
		aluop_o <= `EXE_NOP;
		mem_addr_o <= `ZERO_WORD;
    end
    else if (rdy == `Disable) begin
    end
	else if (stall[2] == `Enable) begin
	end
    else begin
        mem_rd_data <= ex_rd_data;
        mem_rd_addr <= ex_rd_addr;
        mem_rd_enable <= ex_rd_enable;
		aluop_o <= aluop_i;
		mem_addr_o <= mem_addr_i;
    end
end

endmodule
