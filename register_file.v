module register_file(clk, read_addr1, read_addr2, write_addr, read_data1, read_data2, write_data, regwrite_en);

parameter ADDRESS_WIDTH = 5;
parameter DATA_WIDTH = 32;

input clk, regwrite_en;
input [ADDRESS_WIDTH-1:0] read_addr1, read_addr2, write_addr;
input [DATA_WIDTH-1:0] write_data;
output [DATA_WIDTH-1:0] read_data1, read_data2;

reg [DATA_WIDTH-1:0] registers [0:2**ADDRESS_WIDTH-1];

integer i;
initial begin
	for(i = 0; i < 2**ADDRESS_WIDTH; i=i+1)
		registers[i] = 0;
end

assign read_data1 = registers[read_addr1];
assign read_data2 = registers[read_addr2];

always@(posedge clk) begin 
	if (regwrite_en) registers[write_addr] = write_data;
	registers[0] = 0;
end

endmodule
