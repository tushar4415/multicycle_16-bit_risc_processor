`include "IM.v"
`include "control.v"
module tbimctrl;
wire PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond;
wire [1:0] ALU_Src_A;
wire [2:0] ALU_Src_B;
wire [1:0] RegA_Sel;
wire RegC_Sel;
wire [3:0] opcode;
reg clk;
wire [3:0] p_state, n_state;
wire opcode_flag;

wire [15:0] instr_reg;
reg [15:0] PCReg;



control c1(PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, RegA_Sel, RegC_Sel, opcode, clk, p_state, n_state, opcode_flag);
instr_mem im1(instr_reg, IM_Read, PCReg);
assign opcode = instr_reg[15:12];

initial begin
    clk = 1'b1;
   // opcode = instr_reg[15:12];
    PCReg = 16'b0; 
end
initial begin
    forever #1 clk = ~clk;        
end
initial begin
    //$monitor($time, " PC_Sel = %b, PC_Wr = %b, IM_Read = %b, DM_Read = %b, DM_Wr = %b,\n Reg_Dst = %b, Mem_to_Reg = %b, Reg_Wr = %b, Data_Src = %b, PC_Wr_Cond = %b,\n ALU_Src_A = %b, ALU_Src_B = %b, opcode = %b, p_state = %b\n",PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, opcode, p_state);
    #2 $display($time, " opcode = %b", opcode);
end
initial begin
    #21 $finish;
end
endmodule