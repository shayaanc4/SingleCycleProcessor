module pc_updater(pc, imm, alu_result, s, pc_next);

parameter PC_WIDTH = 8;
parameter DATA_WIDTH = 32;

input signed [PC_WIDTH-1:0] pc;
input [3:0] s;
input signed [DATA_WIDTH-1:0] imm;
input [DATA_WIDTH-1:0] alu_result;
output reg signed [PC_WIDTH-1:0] pc_next;

always@* begin
	casez (s)
		4'b111?: pc_next = pc + (imm << 1);
		4'b101?: pc_next = alu_result;
		4'b1001: pc_next = pc + (imm << 1);
		default: pc_next = pc + 4;
	endcase
end

endmodule
