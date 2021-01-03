`include "config.v"

module register(
    input wire clk,
    input wire rst,
    input wire rdy,
    //write
    input wire write_enable,
    input wire [`RegAddrLen - 1 : 0] write_addr,
    input wire [`RegLen - 1 : 0] write_data,
    //read 1
    input wire read_enable1,   
    input wire [`RegAddrLen - 1 : 0] read_addr1,
    output reg [`RegLen - 1 : 0] read_data1,
    //read 2
    input wire read_enable2,   
    input wire [`RegAddrLen - 1 : 0] read_addr2,
    output reg [`RegLen - 1 : 0] read_data2
);
    
reg[`RegLen - 1 : 0] regs[`RegNum - 1 : 0];
integer i;
    
//write 1
always @ (posedge clk) begin
	if (rst == `Enable) begin
		for (i = 0; i < `RegNum; i = i + 1)
            regs[i] = `ZERO_WORD;
	end
    else if (rdy == `Disable) begin
    end
	else if (write_enable == `Enable) begin
        if (write_addr != `ZeroReg) //not zero register
            regs[write_addr] <= write_data;
    end
end

//read 1
always @ (*) begin
    if (rst == `Disable && read_enable1 == `Enable) begin
        if (read_addr1 == `ZeroReg)
            read_data1 = `ZERO_WORD;
        else if (read_addr1 == write_addr && write_enable == `Enable)
            read_data1 = write_data;
        else
            read_data1 = regs[read_addr1];
    end
    else begin
        read_data1 = `ZERO_WORD;
    end
end

//read 2
always @ (*) begin
    if (rst == `Disable && read_enable2 == `Enable) begin
        if (read_addr2 == `ZeroReg)
            read_data2 = `ZERO_WORD;
        else if (read_addr2 == write_addr && write_enable == `Enable)
            read_data2 = write_data;
        else
            read_data2 = regs[read_addr2];
    end
    else begin
        read_data2 = `ZERO_WORD;
    end
end

endmodule
