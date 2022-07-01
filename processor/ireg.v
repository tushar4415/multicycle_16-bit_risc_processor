module ireg (
    output reg [3:0] op,
    input IM_Read
);
reg [15:0] inst[1:0];
integer i;
initial begin
    inst[0] = 16'b1001001110010000;
    inst[1] = 16'b1010001100010000;
    i = 0;
end
always @(posedge IM_Read) begin
    op = inst[i][15:12];
    i = i + 1;
end

    
endmodule