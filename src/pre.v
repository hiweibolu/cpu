`include "config.v"

module pre(

    input wire clk,
    input wire rst,
    input wire rdy,

    // IF
	input wire [`AddrLen - 1 : 0] pc_if,
	output reg predict_jump,
	output reg [`AddrLen - 1 : 0] predict_jump_target,
	
	// EX
	input wire [`AddrLen - 1 : 0] pc_ex,
	input wire ex_jump,
	input wire ex_jump_plus,
	input wire [`AddrLen - 1 : 0] ex_jump_target
	
);

reg [1 : 0] history [`IndexLen - 1 : 0];
reg [`TagLen - 1 : 0] tag [`IndexLen - 1 : 0];
reg [`InstLen - 1 : 0] target [`IndexLen - 1 : 0];

// IF
always @ (*) begin
    if (rst == `Enable) begin
		predict_jump = `Disable;
		predict_jump_target = `ZERO_WORD;
    end 
	else if (tag[pc_if[`IndexBus]] == pc_if[`TagBus] && history[pc_if[`IndexBus]][1] == 1'b1) begin
		predict_jump = `Enable;
		predict_jump_target = target[pc_if[`IndexBus]];
	end
	else begin
		predict_jump = `Disable;
		predict_jump_target = `ZERO_WORD;
	end
end

// EX
integer i;
always @ (posedge clk) begin
    if (rst) begin
        for (i = 0; i < `IndexLen; i = i + 1) begin
            tag[i][`TagLen - 1] <= 1;
			history[i] <= 2'b10;
        end
    end 
    else if (rdy == `Disable) begin
    end
	else if (ex_jump) begin
        if (ex_jump_plus) begin
			tag[pc_ex[`IndexBus]] <= pc_ex[`TagBus];
			target[pc_ex[`IndexBus]] <= ex_jump_target;
			if (history[pc_ex[`IndexBus]] != 2'b11) 
				history[pc_ex[`IndexBus]] <= history[pc_ex[`IndexBus]] + 1;
        end 
		else begin
			tag[pc_ex[`IndexBus]] <= pc_ex[`TagBus];
			target[pc_ex[`IndexBus]] <= ex_jump_target;
			if (history[pc_ex[`IndexBus]] != 2'b00) 
				history[pc_ex[`IndexBus]] <= history[pc_ex[`IndexBus]] - 1;
        end
    end
end

endmodule
