`include "config.v"

// RISCV32I CPU top module
// port modification allowed for debugging purposes

module cpu(
  input  wire                 clk_in,			// system clock signal
  input  wire                 rst_in,			// reset signal
	input  wire					        rdy_in,			// ready signal, pause cpu when low

  input  wire [ 7:0]          mem_din,		// data input bus
  output wire [ 7:0]          mem_dout,		// data output bus
  output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
  output wire                 mem_wr,			// write/read signal (1 for write)
	
	input  wire                 io_buffer_full, // 1 if uart buffer is full
	
	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read result will be returned in the next cycle. Write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

always @(posedge clk_in)
  begin
    if (rst_in)
      begin
      
      end
    else if (!rdy_in)
      begin
      
      end
    else
      begin
      
      end
  end


//PC -> IF/ID
wire [`AddrLen - 1 : 0] pc;

//IF/ID -> ID
wire [`AddrLen - 1 : 0] id_pc_i;
wire [`InstLen - 1 : 0] id_inst_i;

//Register -> ID
wire [`RegLen - 1 : 0] reg1_data;
wire [`RegLen - 1 : 0] reg2_data;

//ID -> Register
wire [`RegAddrLen - 1 : 0] reg1_addr;
wire reg1_read_enable;
wire [`RegAddrLen - 1 : 0] reg2_addr;
wire reg2_read_enable;

//ID -> ID/EX
wire [`OpCodeLen - 1 : 0] id_aluop;
wire [`OpSelLen - 1 : 0] id_alusel;
wire [`RegLen - 1 : 0] id_reg1, id_reg2, id_Imm;
wire [`RegAddrLen - 1 : 0] id_rd;
wire id_rd_enable;

//ID/EX -> EX
wire [`OpCodeLen - 1 : 0] ex_aluop;
wire [`OpSelLen - 1 : 0] ex_alusel;
wire [`RegLen - 1 : 0] ex_reg1, ex_reg2, ex_Imm;
wire [`RegAddrLen - 1 : 0]  ex_rd;
wire ex_rd_enable_i;

//EX -> EX/MEM
wire [`RegLen - 1 : 0] ex_rd_data_o;
wire [`RegAddrLen - 1 : 0] ex_rd_addr_o;
wire ex_rd_enable_o;

//EX/MEM -> MEM
wire [`RegLen - 1 : 0] mem_rd_data_i;
wire [`RegAddrLen - 1 : 0] mem_rd_addr_i;
wire mem_rd_enable_i;

//MEM -> MEM/WB
wire [`RegLen - 1 : 0] mem_rd_data_o;
wire [`RegAddrLen - 1 : 0] mem_rd_addr_o;
wire mem_rd_enable_o;

//MEM/WB -> Register
wire write_enable;
wire [`RegAddrLen - 1 : 0] write_addr;
wire [`RegLen - 1 : 0] write_data;

wire [`StallLen - 1 : 0] stall_text;

wire ex_jump_mistake;
wire [`AddrLen - 1 : 0] ex_jump_target;
wire predictor_jump;
wire [`AddrLen - 1 : 0] predictor_jump_target;
wire [`AddrLen - 1 : 0] if_pc;
wire id_jump;

wire [`InstLen - 1 : 0] inst;
wire [`InstLen - 1 : 0] if_inst;
wire inst_done;
wire [`AddrLen - 1 : 0] inst_addr;
wire [`AddrLen - 1 : 0] iif_pc;
wire inst_read_enable;
wire if_stall;

wire ex_load;
wire [`AddrLen - 1 : 0] id_ex_pc;
wire id_stall;

wire ex_jump;
wire [`AddrLen - 1 : 0] ex_pc;

wire ex_predictor_jump;
wire jump_plus;
wire [`OpCodeLen - 1 : 0] aluop_o;
wire [`AddrLen - 1 : 0] mem_addr_o;

wire [`OpCodeLen - 1 : 0] mem_aluop;
wire [`RegLen - 1 : 0] mem_addr;

wire mem_stall;
wire ram_done;
wire [`RegLen - 1 : 0] ram_data;
wire ram_read_enable;
wire ram_write_enable;
wire [`RegLen - 1 : 0] ram_addr_o;
wire [`RegLen - 1 : 0] ram_data_o;
wire [1 : 0] ram_offset;


wire [`AddrLen - 1 : 0] ex_target;

wire mem_wr_o;
assign mem_wr = mem_wr_o & rdy_in;

//assign rom_addr_o = pc;

//Instantiation
pc_reg pc_reg0(

	//in
		.clk(clk_in), .rst(rst_in), .rdy(rdy_in),
		.stall(stall_text),
		.jump_mistake(ex_jump_mistake), .correct_target(ex_jump_target),
		.jump_predict(predictor_jump), .predict_target(predictor_jump_target),
	
	//out
		.pc(if_pc),
		.jump(id_jump)
	
);

if_ if0(
	//in
		.clk(clk_in), .rst(rst_in), .rdy(rdy_in),

		.pc(if_pc),
		.inst(inst), .inst_done(inst_done), .inst_addr_i(inst_addr),
	
	//out
		.pc_o(iif_pc),
		.inst_o(if_inst),
	
		.inst_read_enable(inst_read_enable),
	
		.stall(if_stall)
);

if_id if_id0(

	//in
		.clk(clk_in), .rst(rst_in), .rdy(rdy_in), 
		.if_pc(iif_pc), .if_inst(if_inst), 
		.stall(stall_text), .jump_mistake(ex_jump_mistake),
		
	//out
		.id_pc(id_pc_i), .id_inst(id_inst_i)
		
);

id id0(

	//in 
	
		.rst(rst_in), .pc(id_pc_i), .inst(id_inst_i), 
		
		.reg1_data_i(reg1_data), 
		.reg2_data_i(reg2_data), 
		
		//data forwarding
		.ex_mem_data_i(ex_rd_data_o), 
		.ex_mem_rd_i(ex_rd_addr_o), 
		.ex_mem_rd_enable(ex_rd_enable_o),
		
		.mem_wb_data_i(mem_rd_data_o), 
		.mem_wb_rd_i(mem_rd_addr_o),
		.mem_wb_rd_enable(mem_rd_enable_o),
		
		.ex_load_enable(ex_load),
		
	//out
		.reg1_read_enable(reg1_read_enable), 
		.reg2_read_enable(reg2_read_enable),
		.reg1_addr_o(reg1_addr), .reg2_addr_o(reg2_addr),
		
		.reg1(id_reg1), .reg2(id_reg2), 
		.Imm(id_Imm), .rd(id_rd), .rd_enable(id_rd_enable), 
		.aluop(id_aluop), .alusel(id_alusel),
		.pc_o(id_ex_pc),
		.stall(id_stall)
);

id_ex id_ex0(

	//in
		.clk(clk_in), .rst(rst_in), .rdy(rdy_in),
		.stall(stall_text),
		
		.id_reg1(id_reg1), .id_reg2(id_reg2), 
		.id_Imm(id_Imm), .id_rd(id_rd), .id_rd_enable(id_rd_enable), 
		.id_aluop(id_aluop), .id_alusel(id_alusel),
		
		.jump_i(id_jump),
		.jump_mistake(ex_jump_mistake),
		.id_pc(id_ex_pc),
		
	//out
		.ex_reg1(ex_reg1), .ex_reg2(ex_reg2), 
		.ex_Imm(ex_Imm), .ex_rd(ex_rd), .ex_rd_enable(ex_rd_enable_i), 
		.ex_aluop(ex_aluop), .ex_alusel(ex_alusel),
		.ex_pc(ex_pc), .jump_o(ex_jump)
);			

ex ex0(

	//in 
		.rst(rst_in), 
		
		.reg1(ex_reg1), .reg2(ex_reg2), 
		.Imm(ex_Imm), .rd(ex_rd), .rd_enable(ex_rd_enable_i), 
		.aluop(ex_aluop), .alusel(ex_alusel),
		.pc(ex_pc),
		.jump_i(ex_jump),
	
	//out
		.rd_data_o(ex_rd_data_o),
		.rd_addr(ex_rd_addr_o),
		.rd_enable_o(ex_rd_enable_o),
		.jump_target(ex_jump_target),
		.jump_mistake(ex_jump_mistake),
		.predictor_jump(ex_predictor_jump),
		.predictor_jump_plus(jump_plus),
        .predictor_jump_target(ex_target),
		.aluop_o(aluop_o),
		.mem_addr_o(mem_addr_o),
		.load_enable_o(ex_load)

);

ex_mem ex_mem0(

	//in
		.clk(clk_in), .rst(rst_in), .rdy(rdy_in),
		.stall(stall_text),
		.aluop_i(aluop_o),
		.mem_addr_i(mem_addr_o),
		
		.ex_rd_data(ex_rd_data_o),
		.ex_rd_addr(ex_rd_addr_o), 
		.ex_rd_enable(ex_rd_enable_o),
		
	//out
        .mem_rd_data(mem_rd_data_i), 
		.mem_rd_addr(mem_rd_addr_i), 
		.mem_rd_enable(mem_rd_enable_i),
		.aluop_o(mem_aluop),
		.mem_addr_o(mem_addr)
);

mem mem0(

	//in
		.rst(rst_in),
		
        .rd_data_i(mem_rd_data_i), 
		.rd_addr_i(mem_rd_addr_i), 
		.rd_enable_i(mem_rd_enable_i),
		
		.aluop(mem_aluop),
		.mem_addr_i(mem_addr),

		.ram_done(ram_done),
		.ram_data(ram_data),

		
	//out
		.ram_read_enable(ram_read_enable),
		.ram_write_enable(ram_write_enable),
		.ram_addr_o(ram_addr_o),
		.ram_data_o(ram_data_o),
		.ram_offset(ram_offset),
	
		.stall(mem_stall),

        .rd_data_o(mem_rd_data_o), 
		.rd_addr_o(mem_rd_addr_o), 
		.rd_enable_o(mem_rd_enable_o)
);

mem_wb mem_wb0(

	//in
		.clk(clk_in), .rst(rst_in), .rdy(rdy_in),
		.stall(stall_text),
		
        .mem_rd_data(mem_rd_data_o), 
		.mem_rd_addr(mem_rd_addr_o), 
		.mem_rd_enable(mem_rd_enable_o),
		
	//out
        .wb_rd_data(write_data), 
		.wb_rd_addr(write_addr), 
		.wb_rd_enable(write_enable)
);

      
register register0(
	//in
		 .clk(clk_in), .rst(rst_in), .rdy(rdy_in),
         .write_enable(write_enable), 
		 .write_addr(write_addr), 
		 .write_data(write_data),
		 
		.read_enable1(reg1_read_enable), .read_addr1(reg1_addr), 
	    .read_enable2(reg2_read_enable), .read_addr2(reg2_addr), 

	//out		
		.read_data1(reg1_data),
		.read_data2(reg2_data)
);

stall stall0(
	//in
		.rst(rst_in),

		.if_stall(if_stall),
		.id_stall(id_stall),
		.mem_stall(mem_stall),
	
    //out
		.stall(stall_text)

);

pre pre0(
	//in 
		.clk(clk_in), .rdy(rdy_in),
		.rst(rst_in),

		.pc_if(if_pc),
		
		.pc_ex(ex_pc),
		.ex_jump(predictor_jump),
		.ex_jump_target(ex_target),
		.ex_jump_plus(jump_plus),
	//out 
		.predict_jump(predictor_jump),
		.predict_jump_target(predictor_jump_target)
);

mem_ctrl mem_ctrl0(
	//in 
		.clk(clk_in), .rdy(rdy_in),
		.rst(rst_in),
		
		.inst_read_enable(inst_read_enable),
		.inst_addr_i(if_pc),
		
		.ram_read_enable(ram_read_enable),
		.ram_write_enable(ram_write_enable),
		.ram_addr_i(ram_addr_o),
		.ram_data_i(ram_data_o),
		.ram_offset_i(ram_offset),
		.mem_din(mem_din),
	// out 
	
		.ram_done_o(ram_done),
		.ram_data_o(ram_data),
		.inst_o(inst),
		.inst_addr_o(inst_addr),
		.inst_done(inst_done),
		
		.mem_dout(mem_dout),
		.mem_a(mem_a),
		.mem_wr(mem_wr_o),
		.io_buffer_full(io_buffer_full)
);

endmodule