`include "config.v"

module mem_ctrl(

    input wire clk,
    input wire rst,
    input wire rdy,
	
	input wire inst_read_enable,
	input wire [`AddrLen - 1 : 0] inst_addr_i,
	
	output reg [`InstLen - 1 : 0] inst_o,
	output reg [`AddrLen - 1 : 0] inst_addr_o,
	output reg inst_done,
	
	input wire ram_read_enable,
	input wire ram_write_enable,
	input wire [`AddrLen - 1 : 0] ram_addr_i,
	input wire [`RegLen - 1 : 0] ram_data_i,
	input wire [1 : 0] ram_offset_i,
	
	output reg ram_done_o,
	output reg [`RegLen - 1 : 0] ram_data_o,
	
	input wire [`ByteLen - 1 : 0] mem_din,
	input wire io_buffer_full,
	output reg [`ByteLen - 1 : 0] mem_dout,
	output reg [`AddrLen - 1 : 0] mem_a,
	output reg mem_wr
	
);

reg work;
reg write;
reg [2 : 0] offset;
reg work_for_if;
reg [`RegLen - 1 : 0] ram_data;
reg [`AddrLen - 1 : 0] ram_addr;
    
always @ (posedge clk) begin
    if (rst == `Enable) begin
		work <= `Disable;
		write <= `Disable;
		offset <= 3'b0;
		work_for_if <= `Disable;
		
		ram_data <= `ZERO_WORD;
		ram_addr <= `ZERO_WORD;
		
		inst_o <= `ZERO_WORD;
		inst_addr_o <= `ZERO_WORD;
		inst_done <= `Disable;
		
		ram_done_o <= `Disable;
		ram_data_o <= `ZERO_WORD;
		
		mem_dout <= `ZERO_BYTE;
		mem_a <= `ZERO_WORD;
		mem_wr <= `Disable;
		
    end	
    else if (rdy == `Disable) begin
    end
    else if (io_buffer_full == `Enable) begin
        ram_done_o <= `Disable;
        inst_done <= `Disable;
        mem_a <= `ZERO_WORD;
        mem_wr <= `Disable;
    end
	else begin
		if (work == `Disable) begin
			if (ram_done_o == `Disable && ram_write_enable == `Enable) begin
				inst_done <= `Disable;
				
				ram_addr <= ram_addr_i;
				ram_data <= ram_data_i;

				mem_a <= ram_addr_i + ram_offset_i;
				mem_wr <= `Enable;
				
				work_for_if <= `Disable;
				work <= ram_offset_i != 2'b00;
				write <= `Enable;
				offset <= ram_offset_i;
				ram_done_o <= ram_offset_i == 2'b00;
				
				case (ram_offset_i)
					2'b11: mem_dout <= ram_data_i[31 : 24];
					2'b01: mem_dout <= ram_data_i[15 : 8];
					2'b00: mem_dout <= ram_data_i[7 : 0];
				endcase 
			end
			else if (ram_done_o == `Disable && ram_read_enable == `Enable) begin
				inst_done <= `Disable;
				
				ram_addr <= ram_addr_i;

				mem_a <= ram_addr_i + ram_offset_i;
				mem_wr <= `Disable;
				
				work_for_if <= `Disable;
				
				work <= `Enable;
				write <= `Disable;
				offset <= {1'b0, ram_offset_i} + 1;

			end
			else if (inst_read_enable == `Enable) begin
				ram_done_o <= `Disable;
				inst_done <= `Disable;
				
				ram_addr <= inst_addr_i;
				
				mem_a <= inst_addr_i + 3;
				mem_wr <= `Disable;
				
				work_for_if <= `Enable;
				
				work <= `Enable;
				write <= `Disable;
				offset <= 3'h4;
			end
			else begin
				ram_done_o <= `Disable;
				inst_done <= `Disable;
				mem_a <= `ZERO_WORD;
				mem_wr <= `Disable;
			end
		end
		else begin
			if (write == `Enable) begin
				ram_done_o <= `Disable;
				inst_done <= `Disable;
				case (offset)
					3'h3: begin
						mem_dout <= ram_data[23 : 16];
						mem_a <= ram_addr + 2;
						mem_wr <= `Enable;
						
						offset <= 3'h2;
					end
					3'h2: begin
						mem_dout <= ram_data[15 : 8];
						mem_a <= ram_addr + 1;
						mem_wr <= `Enable;
						
						offset <= 3'h1;
					end
					3'h1: begin
						mem_dout <= ram_data[7 : 0];
						mem_a <= ram_addr;
						mem_wr <= `Enable;
						
						work <= `Disable;
						
						ram_done_o <= `Enable;
					end
				endcase
			end
			else
			begin
				ram_done_o <= `Disable;
				inst_done <= `Disable;
				case (offset)
					3'h4: begin
						mem_a <= ram_addr + 2;
						mem_wr <= `Disable;
						offset <= 3'h3;
					end
					3'h3: begin
						ram_data[31 : 24] <= mem_din;
						mem_a <= ram_addr + 1;
						mem_wr <= `Disable;
						offset <= 3'h2;
					end
					3'h2: begin
						ram_data[23 : 16] <= mem_din;
						mem_a <= ram_addr;
						mem_wr <= `Disable;
						offset <= 3'h1;
					end
					3'h1: begin
						ram_data[15 : 8] <= mem_din;
						offset <= 3'h0;
					end
					3'h0: begin
						work = `Disable;

						if (work_for_if == `Enable) begin
							inst_addr_o <= ram_addr;
							inst_o <= {ram_data[31 : 8], mem_din};
							inst_done <= `Enable;
						end else begin
							ram_done_o <= `Enable;
							ram_data_o <= {ram_data[31 : 8], mem_din};
						end
					end
				endcase 
			end
		end
	end
end
endmodule
