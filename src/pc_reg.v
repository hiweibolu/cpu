`include "config.v"

module pc_reg(

    input wire clk,
    input wire rst,
    input wire rdy,
	
	input wire [`StallLen - 1 : 0] stall,
	
	input wire jump_mistake,
	input wire [`AddrLen - 1 : 0] correct_target,
	
	input wire jump_predict,
	input wire [`AddrLen - 1 : 0] predict_target,
	
    output reg [`AddrLen - 1 : 0] pc,
	output reg jump
);

always @ (posedge clk) begin
    if (rst == `Enable) begin
        pc <= `ZERO_WORD;
		jump <= `Disable;
    end 
    else if (rdy == `Disable) begin
    end
	else if (jump_mistake == `Enable) begin
		pc <= correct_target;
		jump <= `Disable;
	end
	else if (stall[0] == `Enable) begin
	end
	else if (jump_predict == `Enable) begin
		pc <= predict_target;
		jump <= `Enable;
	end
    else begin
        pc <= pc + 4;
		jump <= `Disable;
    end
end

endmodule
