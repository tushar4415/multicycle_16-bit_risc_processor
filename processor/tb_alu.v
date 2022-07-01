`include "alu_temp.v"
module tb_alu;
wire [15:0]ALUOut;
wire zero_flag;
reg [15:0]SrcA,SrcB;
reg [2:0]ALUCtrl;

main_ALU a1(ALUOut, zero_flag, SrcA, SrcB, ALUCtrl);

initial begin
    SrcA = 16'hA;//16'b1100_1100_1100_1100;
	SrcB = 16'hA;//16'b0110_0110_0110_0110;
    ALUCtrl = 3'b011;
end

initial begin
    $display("A = %b, B = %b", SrcA, SrcB);
    #1 $display("ALUOut = %h", zero_flag);
end
endmodule