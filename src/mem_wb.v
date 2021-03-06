`include "config.v"

module mem_wb(
    input clk,
    input rst,
    input wire rdy,
	
    input wire [`RegLen - 1 : 0] mem_rd_data,
    input wire [`RegAddrLen - 1 : 0] mem_rd_addr,
    input wire mem_rd_enable,
	
	input wire [`StallLen - 1 : 0] stall,

    output reg [`RegLen - 1 : 0] wb_rd_data,
    output reg [`RegAddrLen - 1 : 0] wb_rd_addr,
    output reg wb_rd_enable
);

always @ (posedge clk) begin
    if (rst == `Enable) begin
        wb_rd_data <= `ZERO_WORD;
        wb_rd_addr <= `ZeroReg;
        wb_rd_enable <= `Disable;
    end
    else if (rdy == `Disable) begin
    end
	else if (stall[2] == `Enable) begin
        wb_rd_data <= `ZERO_WORD;
        wb_rd_addr <= `ZeroReg;
        wb_rd_enable <= `Disable;
	end
    else begin
        wb_rd_data <= mem_rd_data;
        wb_rd_addr <= mem_rd_addr;
        wb_rd_enable <= mem_rd_enable;
    end
end
endmodule
