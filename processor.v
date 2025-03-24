module processor(CLOCK_50);

parameter INSTRUCTION_WIDTH = 32;
parameter DATA_WIDTH = 32;
parameter NUM_ALU_OPS = 6;
parameter PC_WIDTH = 8;

input CLOCK_50;
wire rst, locked, clk;

reg signed [PC_WIDTH-1:0] pc;
wire signed [PC_WIDTH:0] pc_next;
wire [INSTRUCTION_WIDTH-1:0] instruction;

wire [DATA_WIDTH-1:0] reg_read_data1, reg_read_data2, reg_write_data, mem_read_data, alu_input1, alu_input2, alu_result;

wire signed [DATA_WIDTH-1:0] imm;

wire [$clog2(NUM_ALU_OPS)-1:0] alu_opcode;
wire branch, memtoreg, memwrite, alusrc, regwrite, z_flag, eq_flag;

initial pc = 0;

always@(posedge clk) if (instruction[6:0] != 7'b1111111) pc <= pc_next;

assign rst = 0;
assign alu_input1 = reg_read_data1;
assign alu_input2 = alusrc ? imm : reg_read_data2;
assign eq_flag = instruction[12] ? ~z_flag : z_flag;

pc_updater pc_u(.pc(pc), .imm(imm), .alu_result(alu_result), .s({branch, instruction[3:2], eq_flag}), .pc_next(pc_next));

PLL pll(.refclk(CLOCK_50), .rst(rst), .locked(locked), .outclk_0(clk));

control_unit control(.instruction(instruction), .branch(branch), .memtoreg(memtoreg), 
							.alu_opcode(alu_opcode), .memwrite(memwrite), .alusrc(alusrc), .regwrite(regwrite));

rom instruction_mem(.addr(pc), .data(instruction));

reg_write_data_selector reg_wd_sel(pc, {instruction[2], memtoreg}, mem_read_data, alu_result, reg_write_data);

register_file rf(
	.clk(clk), .regwrite_en(regwrite),
	.read_addr1(instruction[19:15]), .read_addr2(instruction[24:20]), .write_addr(instruction[11:7]), 
	.read_data1(reg_read_data1), .read_data2(reg_read_data2), .write_data(reg_write_data));
	
imm_gen immgen(.instruction(instruction), .imm(imm));
	
alu alu(.input1(alu_input1), .input2(alu_input2), .opcode(alu_opcode), .result(alu_result), .z_flag(z_flag));

ram_ip data_mem(alu_result, ~clk, reg_read_data2, memwrite, mem_read_data);

endmodule
