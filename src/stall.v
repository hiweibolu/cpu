`include "config.v"

module stall(

    input wire rst,

	input wire if_stall,
	input wire id_stall,
	input wire mem_stall,
	
    output reg [`StallLen - 1 : 0] stall
);

always @ (*) begin
	if (rst == `Enable) begin
        stall = `NoStall;
    end
    else begin
        stall[0] = if_stall | id_stall | mem_stall;
        stall[1] = id_stall | mem_stall;
        stall[2] = mem_stall;
    end
end

endmodule
