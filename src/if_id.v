`include "config.v"

module if_id(

    input wire clk,
    input wire rst,
    input wire rdy,
    input wire [`AddrLen - 1 : 0] if_pc,
    input wire [`InstLen - 1 : 0] if_inst,
	
	input wire jump_mistake,
	input wire [`StallLen - 1 : 0] stall,
	
    output reg [`AddrLen - 1 : 0] id_pc,
    output reg [`InstLen - 1 : 0] id_inst
);
    
always @ (posedge clk) begin
    if (rst == `Enable) begin
        id_pc <= `ZERO_WORD;
        id_inst <= `ZERO_WORD;
    end
    else if (rdy == `Disable) begin
    end
	else if (stall[1] == `Enable) begin
	end
	else if (jump_mistake == `Enable) begin
        id_pc <= `ZERO_WORD;
        id_inst <= `ZERO_WORD;
	end
    else begin
/*if (if_pc == 32'h12d8) begin
    $display("%h",if_pc);
end*/
        id_pc <= if_pc;
        id_inst <= if_inst;
    end
end
endmodule
