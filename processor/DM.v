module data_mem(data_reg, dm_read, dm_wr, addr, wr_data);
input dm_read;
input dm_wr;
input [15:0] addr;
input [15:0] wr_data;
output reg [15:0] data_reg;
reg [7:0] memory [65535:0];
//reg [15:0] dont_care = {16{1'bx}};

always @(posedge dm_wr)
begin
	{memory[addr+1], memory[addr]} = wr_data;
end

always @(posedge dm_read) begin
	data_reg = {memory[addr+1], memory[addr]};
end



endmodule