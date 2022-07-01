module reg_file(regouttest, read_data_a, read_data_b, read_data_c, read_addr_1, read_addr_2, read_addr_3, write_addr, write_data, reg_wr);
input reg_wr;
input [3:0] read_addr_1;
input [3:0] read_addr_2;
input [3:0] read_addr_3;
input [3:0] write_addr;
input [15:0] write_data;
output reg [15:0] regouttest;
output reg [15:0] read_data_a;
output reg [15:0] read_data_b;
output reg [15:0] read_data_c;
reg [15:0] registers [0:15];

initial begin
	registers[0] = 16'b0;
end

always @(posedge reg_wr)
begin
	registers[write_addr]=write_data;
end
always @(*) begin
	read_data_a = registers[read_addr_1];
	read_data_b = registers[read_addr_2];
	read_data_c = registers[read_addr_3];
end

initial begin
    registers[9] = 16'h1010;
    registers[1] = 16'h0101;
	registers[3] = 16'h0005;
end
// always @(*) begin
// 	//regouttest = registers[3];
// end


endmodule