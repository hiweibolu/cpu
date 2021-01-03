`include "config.v"

module if_(

    input wire clk,
    input wire rst,
    input wire rdy,

	input wire [`AddrLen - 1 : 0] pc,
	input wire [`InstLen - 1 : 0] inst,
	input wire inst_done,
	input wire [`AddrLen - 1 : 0] inst_addr_i,
	
	output reg [`AddrLen - 1 : 0] pc_o,
	output reg [`InstLen - 1 : 0] inst_o,
	
	output reg inst_read_enable,
	
	output reg stall
);

reg [`TagLen - 1 : 0] tag [`IndexLen - 1 : 0];
reg [`InstLen - 1 : 0] data [`IndexLen - 1 : 0];

integer i;
always @ (posedge clk) begin
    if (rst) begin
        for (i = 0; i < `IndexLen; i = i + 1) begin
            tag[i][`TagLen - 1] <= 1;
        end
    end 
    else if (rdy == `Disable) begin
    end
	else if (inst_done) begin
        tag[inst_addr_i[`IndexBus]] <= inst_addr_i[`TagBus];
        data[inst_addr_i[`IndexBus]] <= inst;
    end
end

always @ (*) begin
    if (rst == `Enable) begin
		inst_o = `ZERO_WORD;
        pc_o = `ZERO_WORD;
		stall = `Disable;
		inst_read_enable = `Disable;
    end 
	else if (tag[pc[`IndexBus]] == pc[`TagBus]) begin
		inst_o = data[pc[`IndexBus]];
        pc_o = pc;
		stall = `Disable;
		inst_read_enable = `Disable;
	end
    else begin
		inst_o = `ZERO_WORD;
        pc_o = `ZERO_WORD;
		stall = `Enable;
		inst_read_enable = ~inst_done;
    end
end

endmodule
