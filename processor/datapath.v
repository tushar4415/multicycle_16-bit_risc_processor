`include "control.v"
`include "alu.v"
`include "DM.v"
`include "IM.v"
`include "Reg_File.v"
`include "alu_control.v"
`include "pc.v"
`include "mux.v"
module datapath;
wire[15:0] regouttest;
wire PC_Wr_Comp1;
wire PC_Write_Combined, PC_Wr_Comp2;
wire[15:0] PCReg_in;

//wire [15:0] Data_Src_Out;
wire [15:0] zero_pad_8, zero_pad_4;
wire [15:0] sign_ext_12, sign_ext_8, sign_ext_ls;
reg [15:0] ALU_inA, ALU_inB;
wire [15:0] PCReg;
//Control signal declaration
wire PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src;
wire [1:0] PC_Wr_Cond;
wire [1:0] ALU_Src_A;
wire [2:0] ALU_Src_B;
wire [1:0] RegA_Sel;
wire RegC_Sel;
wire csig;
wire [3:0] opcode;
wire[3:0] func_field;
reg clk;
wire [3:0] p_state, n_state;
wire opcode_flag;
//ALU Signal
wire [15:0]ALUOut;
reg [15:0] ALUOut_Reg;
wire zero_flag;
//reg [15:0] SrcA,SrcB;
wire [2:0] ALUCtrl;
//IM DM
wire [15:0] instr_reg;
wire [15:0] data_reg;
//RegFile
wire [3:0] RegA, RegB, RegC, Reg_Wr_Addr;
wire [15:0] Reg_Wr_Data;
wire [15:0] read_data_a, read_data_b, read_data_c;



control c1(PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, RegA_Sel, RegC_Sel, csig, opcode, clk, p_state, n_state, opcode_flag);
alu_control ac1(ALUCtrl, opcode, func_field, csig);
main_ALU a1(ALUOut, zero_flag, ALU_inA, ALU_inB, ALUCtrl);

instr_mem im1(instr_reg, IM_Read, PCReg);
data_mem d1(data_reg, DM_Read, DM_Wr, ALUOut_Reg, read_data_c);
reg_file r1(regouttest, read_data_a, read_data_b, read_data_c, RegA, RegB, RegC, Reg_Wr_Addr, Reg_Wr_Data, Reg_Wr);
pc p1(PCReg, ALUOut_Reg, read_data_c, PC_Sel, PC_Write_Combined);

assign opcode = instr_reg[15:12];
assign func_field = instr_reg[3:0];

assign PC_Wr_Comp1 = |PC_Wr_Cond;
assign PC_Wr_Comp2 = PC_Wr_Comp1 ^ zero_flag;
assign PC_Write_Combined = PC_Wr | PC_Wr_Comp2;

always @(*) begin
    ALUOut_Reg = ALUOut;
end

// mux_2to1_16bit m5(PCReg_in, ALUOut_Reg, read_data_c, PCSel);
// always @(posedge PC_Write_Combined) begin
//     PCReg = PCReg_in;
// end

mux_4to1_assign m1(RegA, instr_reg[7:4], instr_reg[11:8], {2'b10, instr_reg[9:8]}, 4'b0, RegA_Sel);
assign RegB = instr_reg[3:0];
mux_4to1_assign m2(RegC, instr_reg[11:8], {2'b11, instr_reg[11:10]}, 4'b0, 4'b0, {1'b0,RegC_Sel});
mux_4to1_assign m3(Reg_Wr_Addr, {2'b11, instr_reg[11:10]}, instr_reg[11:8], 4'b0, 4'b0, {1'b0, Reg_Dst});
mux_2to1_16bit m4(Reg_Wr_Data, data_reg, read_data_c, Mem_to_Reg);



assign zero_pad_4 = {12'b0, instr_reg[7:4]};
assign zero_pad_8 = {{8'b0}, instr_reg[7:0]};
assign sign_ext_12 = {{4{instr_reg[11]}}, instr_reg[11:0]};
assign sign_ext_8 = {{8{instr_reg[7]}}, instr_reg[7:0]};
assign sign_ext_ls = {{7{instr_reg[7]}}, instr_reg[7:0], 1'b0};

always @(*) begin
    case (ALU_Src_A)
        2'b00: ALU_inA = PCReg;
        2'b01: ALU_inA = read_data_a;
        2'b10: ALU_inA = read_data_c;
        default: ALU_inA = PCReg;
    endcase
end

always @(*) begin
    case (ALU_Src_B)
        3'b000: ALU_inB = read_data_b;
        3'b001: ALU_inB = 16'h0002;
        3'b010: ALU_inB = sign_ext_12;
        3'b011: ALU_inB = sign_ext_8;
        3'b100: ALU_inB = zero_pad_8;
        3'b101: ALU_inB = sign_ext_ls;
        3'b110: ALU_inB = zero_pad_4;
        default: ALU_inB = 16'h0002;
    endcase
end

//Testing
initial begin
    clk = 1'b1; 
    // opcode = 4'b0;
    ALUOut_Reg = 16'b0;
end
initial begin
    forever #1 clk = ~clk;        
end
initial begin
    $monitor($time, " PC_Sel = %b, PC_Wr = %b, IM_Read = %b, DM_Read = %b, DM_Wr = %b,\n Reg_Dst = %b, Mem_to_Reg = %b, Reg_Wr = %b, Data_Src = %b, PC_Wr_Cond = %b,\n ALU_Src_A = %b, ALU_Src_B = %b, opcode = %b, Next_state = %b,\n ALUOut = %h, ALUOutReg = %h, inA = %b, inB = %b, Ctrl = %b\n PCReg = %b, PCWComb = %b, zero = %b\n",PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, opcode, p_state, ALUOut, ALUOut_Reg, ALU_inA, ALU_inB, ALUCtrl, PCReg, PC_Write_Combined, zero_flag);

end

initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,datapath);
end

initial begin
    #3 $finish;
end
endmodule