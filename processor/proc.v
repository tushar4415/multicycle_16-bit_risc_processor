//Member1: Ram Goyal (2019A3PS0239P)
//Member2: Tushar Sardana (2019A3PS0260P)
//Member3: Aditya Agarwal (2019A3PS0202P)

module processor;
reg [15:0] PCReg_in;
wire PC_Wr_Comp1;
wire PC_Write_Combined, PC_Wr_Comp2;
wire[15:0] regouttest;
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


control c1(PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, RegA_Sel, RegC_Sel, opcode, clk, p_state, n_state, opcode_flag);
alu_control ac1(ALUCtrl, opcode, func_field);
main_ALU a1(ALUOut, zero_flag, ALU_inA, ALU_inB, ALUCtrl);
instr_mem im1(instr_reg, IM_Read, PCReg);
data_mem d1(data_reg, DM_Read, DM_Wr, ALUOut_Reg, read_data_c);
reg_file r1(regouttest, read_data_a, read_data_b, read_data_c, RegA, RegB, RegC, Reg_Wr_Addr, Reg_Wr_Data, Reg_Wr);
pc p1(PCReg, ALUOut_Reg, read_data_c, PC_Sel, PC_Write_Combined);
assign opcode = instr_reg[15:12];
assign func_field = instr_reg[3:0];
always @(*) begin
    if(PC_Sel)
        PCReg_in = read_data_c;
    else
        PCReg_in = ALUOut_Reg;
end
assign PC_Wr_Comp1 = |PC_Wr_Cond;
assign PC_Wr_Comp2 = PC_Wr_Comp1 ^ zero_flag;
assign PC_Write_Combined = PC_Wr | PC_Wr_Comp2;

always @(*) begin
    ALUOut_Reg = ALUOut;
end


mux_4to1_4bit m1(RegA, instr_reg[7:4], instr_reg[11:8], {2'b10, instr_reg[9:8]}, 4'b0, RegA_Sel);
assign RegB = instr_reg[3:0];
mux_4to1_4bit m2(RegC, instr_reg[11:8], {2'b11, instr_reg[11:10]}, 4'b0, 4'b0, {1'b0,RegC_Sel});
mux_4to1_4bit m3(Reg_Wr_Addr, {2'b11, instr_reg[11:10]}, instr_reg[11:8], 4'b0, 4'b0, {1'b0, Reg_Dst});
mux_2to1_16bit m4(Reg_Wr_Data, data_reg, read_data_c, Mem_to_Reg);


assign zero_pad_4 = {{12'b0}, instr_reg[7:4]};
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
    ALUOut_Reg = 16'b0;
end
initial begin
    forever #1 clk = ~clk;        
end
initial begin
    //$monitor($time," PC_Sel = %b, PC_Wr = %b, IM_Read = %b, DM_Read = %b, DM_Wr = %b,\n Reg_Dst = %b, Mem_to_Reg = %b, Reg_Wr = %b, Data_Src = %b, PC_Wr_Cond = %b,\n ALU_Src_A = %b, ALU_Src_B = %b, opcode = %b, Next_state = %b,\n ALUOut = %h, ALUinA = %b, ALUinB = %b, ALUCtrl = %b,\n RegA_Sel= %b, RegC_Sel= %b, PCReg = %b, PCWrComb = %b, Zero = %b\n", PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, opcode, p_state, ALUOut, ALU_inA, ALU_inB, ALUCtrl, RegA_Sel, RegC_Sel, PCReg, PC_Write_Combined, zero_flag);
	#11 $display($time, " Next State = %b\nImportant Controls: PCSel = %b, PCWrite = %b, IMRead = %b, RegWrite = %b, DMRead = %b, DMWrite = %b\n ALU: ALUControl = %b, ALUinA = %b, ALUinB = %b, ALUOut = %b, Zero = %b\n ", p_state, PC_Sel, PC_Write_Combined, Reg_Wr, IM_Read, DM_Read, DM_Wr, ALUCtrl, ALU_inA, ALU_inB, ALUOut, zero_flag);
	#2 $display($time, " Next State = %b\nImportant Controls: PCSel = %b, PCWrite = %b, IMRead = %b, RegWrite = %b, DMRead = %b, DMWrite = %b\n ALU: ALUControl = %b, ALUinA = %b, ALUinB = %b, ALUOut = %b, Zero = %b\n ", p_state, PC_Sel, PC_Write_Combined, Reg_Wr, IM_Read, DM_Read, DM_Wr, ALUCtrl, ALU_inA, ALU_inB, ALUOut, zero_flag);
	#2 $display($time, " Next State = %b\nImportant Controls: PCSel = %b, PCWrite = %b, IMRead = %b, RegWrite = %b, DMRead = %b, DMWrite = %b\n ALU: ALUControl = %b, ALUinA = %b, ALUinB = %b, ALUOut = %b, Zero = %b\n ", p_state, PC_Sel, PC_Write_Combined, Reg_Wr, IM_Read, DM_Read, DM_Wr, ALUCtrl, ALU_inA, ALU_inB, ALUOut, zero_flag);
	#2 $display($time, " Next State = %b\nImportant Controls: PCSel = %b, PCWrite = %b, IMRead = %b, RegWrite = %b, DMRead = %b, DMWrite = %b\n ALU: ALUControl = %b, ALUinA = %b, ALUinB = %b, ALUOut = %b, Zero = %b\n ", p_state, PC_Sel, PC_Write_Combined, Reg_Wr, IM_Read, DM_Read, DM_Wr, ALUCtrl, ALU_inA, ALU_inB, ALUOut, zero_flag);
	#2 $display($time, " Next State = %b\nImportant Controls: PCSel = %b, PCWrite = %b, IMRead = %b, RegWrite = %b, DMRead = %b, DMWrite = %b\n ALU: ALUControl = %b, ALUinA = %b, ALUinB = %b, ALUOut = %b, Zero = %b\n ", p_state, PC_Sel, PC_Write_Combined, Reg_Wr, IM_Read, DM_Read, DM_Wr, ALUCtrl, ALU_inA, ALU_inB, ALUOut, zero_flag);
	#2 $display($time, " Next State = %b\nImportant Controls: PCSel = %b, PCWrite = %b, IMRead = %b, RegWrite = %b, DMRead = %b, DMWrite = %b\n ALU: ALUControl = %b, ALUinA = %b, ALUinB = %b, ALUOut = %b, Zero = %b\n ", p_state, PC_Sel, PC_Write_Combined, Reg_Wr, IM_Read, DM_Read, DM_Wr, ALUCtrl, ALU_inA, ALU_inB, ALUOut, zero_flag);
end
initial begin
    #20 $finish;
end

endmodule


//control module starts here
module control (
    output reg PC_Sel,
    output reg PC_Wr,
    output reg IM_Read,
    output reg DM_Read,
    output reg DM_Wr,
    output reg Reg_Dst,
    output reg Mem_to_Reg,
    output reg Reg_Wr,
    output reg Data_Src,
    output reg [1:0] PC_Wr_Cond,
    output reg [1:0] ALU_Src_A,
    output reg [2:0] ALU_Src_B,
    output reg [1:0] RegA_Sel,
    output reg RegC_Sel,
    input [3:0] opcode,
    input clk,
    output reg [3:0] p_state,    
    output reg [3:0] n_state,
    output reg opcode_flag
    );

    initial begin
        p_state = 4'b0000;
        opcode_flag = 1'b0;
    end
    
    always @(negedge clk) begin
        case (p_state)
            4'h0: begin
                    PC_Sel = 1'b0; PC_Wr = 1'b1; IM_Read = 1'b1; DM_Read = 1'b0;
                    DM_Wr = 1'b0; Reg_Dst = 1'b0; Mem_to_Reg = 1'b0; Reg_Wr = 1'b0;
                    Data_Src = 1'b1; PC_Wr_Cond = 2'b00; ALU_Src_A = 2'b00; ALU_Src_B = 3'b001;
                    opcode_flag = 1'b1;
                    p_state = 4'h1;
                    RegA_Sel = 2'b0;
                    RegC_Sel = 1'b0;                    
                  end
            4'h1: begin
                    PC_Wr = 1'b0; IM_Read = 1'b0;
                    p_state = n_state;
                  end
            4'h2: begin
                    ALU_Src_A = 2'b10; ALU_Src_B = 3'b110;
                    p_state = 4'hA;
                    RegA_Sel = 2'b01;
                    RegC_Sel = 1'b0;
                  end
            4'h3: begin
                    ALU_Src_A = 2'b11; ALU_Src_B = 3'b101;
                    p_state = 4'hB;
                    RegA_Sel = 2'b10;
                    RegC_Sel = 1'b1;
                  end
            4'h4: begin
                    ALU_Src_A = 2'b00; ALU_Src_B = 3'b010; PC_Wr = 1'b1;
                    p_state = 4'h0;
                  end
            4'h5: begin
                    PC_Wr_Cond = 2'b11; PC_Sel = 1'b1; ALU_Src_A = 2'b01; ALU_Src_B = 4'b0;
                    p_state = 4'h0;
                  end
            4'h6: begin
                    PC_Wr_Cond = 2'b10; PC_Sel = 1'b1; ALU_Src_A = 2'b01; ALU_Src_B = 4'b0;
                    p_state = 4'h0;
                  end
            4'h7: begin
                    ALU_Src_A = 2'b10; ALU_Src_B = 3'b011;
                    p_state = 4'hA;
                    RegA_Sel = 2'b01;
                    RegC_Sel = 1'b0;
                  end
            4'h8: begin
                    ALU_Src_A = 2'b01; ALU_Src_B = 3'b0;
                    p_state = 4'hA;
                  end
            4'h9: begin
                    ALU_Src_A = 2'b10; ALU_Src_B = 3'b100;
                    p_state = 4'hA;
                    RegA_Sel = 2'b01;
                    RegC_Sel = 1'b0;
                  end
            
            4'hA: begin
                    Mem_to_Reg = 1'b1; Reg_Dst = 1'b0; Reg_Wr = 1'b1;
                    p_state = 4'h0;
                  end
            4'hB: begin
                    DM_Read = 1'b1; DM_Wr = 1'b0;
                    p_state = 4'hD;
                  end
            4'hC: begin
                    Data_Src = 1'b0; DM_Wr = 1'b1; DM_Read = 1'b0;
                    p_state = 4'h0;
                  end
            4'hD: begin
                    Reg_Dst = 1'b1; Mem_to_Reg = 1'b0; Reg_Wr = 1'b1;
                    p_state = 4'h0;
                  end
            4'hE: begin
                    ALU_Src_A = 2'b11; ALU_Src_B = 3'b101;
                    p_state = 4'hC;
                    RegA_Sel = 2'b10;
                    RegC_Sel = 1'b1;
                  end

            default: p_state = 4'h0;
        endcase
    end

    always @(posedge opcode_flag) begin
        case (opcode)
            4'h0: n_state = 4'h2;
            4'h1: n_state = 4'h3;
            4'h2: n_state = 4'hE;
            4'h3: n_state = 4'h4;
            4'h4: n_state = 4'h5;
            4'h5: n_state = 4'h6;
            4'h6, 4'h7, 4'h9, 4'hD: n_state = 4'h7;
            4'h8, 4'hB, 4'hC, 4'hF: n_state = 4'h8;
            4'hA, 4'hE: n_state = 4'h9;
            default: n_state = 4'h0;
        endcase
        opcode_flag = 1'b0;
    end
endmodule


//ALU module starts here
module main_ALU(ALUOut, zero_flag, SrcA, SrcB, ALUCtrl);
	output reg [15:0]ALUOut;
	output reg zero_flag;
	input [15:0]SrcA,SrcB;
	input [2:0]ALUCtrl;
	wire carry_out;
	wire [15:0]temp_outA, temp_outB, temp_outC, temp_outD, temp_outE, temp_outF, temp_inB;
	wire temp_zero;
	reg cin;
    assign temp_inB = (ALUCtrl&3'b100)?(~SrcB):(SrcB);
	sixteenbitadder s1(temp_outA,carry_out,SrcA,temp_inB,cin);
	sixteenbitor o1(temp_outB,SrcA,SrcB);
	sixteenbitnand n1(temp_outC,SrcA,SrcB);
	sll_barrel_shifter s2(temp_outD,SrcA,SrcB[3:0]);
	slr_barrel_shifter s3(temp_outE,SrcA,SrcB[3:0]);
	sar_barrel_shifter s4(temp_outF,SrcA,SrcB[3:0]);
	
	
	always @(*) begin
	case(ALUCtrl)
		//sll
		3'b000:
		begin
			ALUOut = temp_outD;
		end
		
		//slr
		3'b001:
		begin
			ALUOut = temp_outE;
		end
		
		//sar
		3'b010:
		begin
			ALUOut = temp_outF;
		end
		
		//add
		3'b011:
		begin
			ALUOut = temp_outA;
			cin = 0;
		end
		
		//sub
		3'b100:
		begin
			ALUOut = temp_outA;
			cin = 1;
		end
		
		//or
		3'b101:
		begin
			ALUOut = temp_outB;
		end
		
		//nand
		3'b110:
		begin
			ALUOut = temp_outC;
		end
		
		
		default:
			ALUOut = 16'b0;
	endcase
	end

	always @(*) begin
	if(~|(ALUOut))
				zero_flag = 1'b1;
			else
				zero_flag = 1'b0;
	end
	
endmodule	
	
module fulladder(a,b,cin,sum,cout);
	output sum,cout;
	input a,b,cin;
	assign sum = (a ^ b ^ cin);
	assign cout= (a & b)|(cin & a)|(b & cin);
endmodule

module sixteenbitadder(Sum,cout,A,B,cin);
	output [15:0] Sum;
	output cout;
	input [15:0] A,B;
	input cin;
	wire [15:0] c;
	fulladder f0(A[0],B[0],cin,Sum[0],c[0]);
	fulladder f1(A[1],B[1],c[0],Sum[1],c[1]);
	fulladder f2(A[2],B[2],c[1],Sum[2],c[2]);
	fulladder f3(A[3],B[3],c[2],Sum[3],c[3]);
	fulladder f4(A[4],B[4],c[3],Sum[4],c[4]);
	fulladder f5(A[5],B[5],c[4],Sum[5],c[5]);
	fulladder f6(A[6],B[6],c[5],Sum[6],c[6]);
	fulladder f7(A[7],B[7],c[6],Sum[7],c[7]);
	fulladder f8(A[8],B[8],c[7],Sum[8],c[8]);
	fulladder f9(A[9],B[9],c[8],Sum[9],c[9]);
	fulladder f10(A[10],B[10],c[9],Sum[10],c[10]);
	fulladder f11(A[11],B[11],c[10],Sum[11],c[11]);
	fulladder f12(A[12],B[12],c[11],Sum[12],c[12]);
	fulladder f13(A[13],B[13],c[12],Sum[13],c[13]);
	fulladder f14(A[14],B[14],c[13],Sum[14],c[14]);
	fulladder f15(A[15],B[15],c[14],Sum[15],c[15]);
	assign cout = c[15];
endmodule

module sixteenbitnand(out,in1,in2);
	output [15:0]out;
	input [15:0]in1,in2;

	nand n0(out[0],in1[0],in2[0]);
	nand n1(out[1],in1[1],in2[1]);
	nand n2(out[2],in1[2],in2[2]);
	nand n3(out[3],in1[3],in2[3]);
	nand n4(out[4],in1[4],in2[4]);
	nand n5(out[5],in1[5],in2[5]);
	nand n6(out[6],in1[6],in2[6]);
	nand n7(out[7],in1[7],in2[7]);
	nand n8(out[8],in1[8],in2[8]);
	nand n9(out[9],in1[9],in2[9]);
	nand n10(out[10],in1[10],in2[10]);
	nand n11(out[11],in1[11],in2[11]);
	nand n12(out[12],in1[12],in2[12]);
	nand n13(out[13],in1[13],in2[13]);
	nand n14(out[14],in1[14],in2[14]);
	nand n15(out[15],in1[15],in2[15]);
endmodule

module sixteenbitor(out,in1,in2);
	output[15:0]out;
	input [15:0]in1,in2;
	
	or o0(out[0],in1[0],in2[0]);
	or o1(out[1],in1[1],in2[1]);
	or o2(out[2],in1[2],in2[2]);
	or o3(out[3],in1[3],in2[3]);
	or o4(out[4],in1[4],in2[4]);
	or o5(out[5],in1[5],in2[5]);
	or o6(out[6],in1[6],in2[6]);
	or o7(out[7],in1[7],in2[7]);
	or o8(out[8],in1[8],in2[8]);
	or o9(out[9],in1[9],in2[9]);
	or o10(out[10],in1[10],in2[10]);
	or o11(out[11],in1[11],in2[11]);
	or o12(out[12],in1[12],in2[12]);
	or o13(out[13],in1[13],in2[13]);
	or o14(out[14],in1[14],in2[14]);
	or o15(out[15],in1[15],in2[15]);
endmodule

module slr_barrel_shifter(q,in,sel);
	output [15:0]q;
	input [15:0]in;
	input[3:0]sel;
	mux m0(q[0],in,sel);
	mux m1(q[1],{1'b0,in[15:1]},sel);
	mux m2(q[2],{2'b0,in[15:2]},sel);
	mux m3(q[3],{3'b0,in[15:3]},sel);
	mux m4(q[4],{4'b0,in[15:4]},sel);
	mux m5(q[5],{5'b0,in[15:5]},sel);
	mux m6(q[6],{6'b0,in[15:6]},sel);
	mux m7(q[7],{7'b0,in[15:7]},sel);
	mux m8(q[8],{8'b0,in[15:8]},sel);
	mux m9(q[9],{9'b0,in[15:9]},sel);
	mux m10(q[10],{10'b0,in[15:10]},sel);
	mux m11(q[11],{11'b0,in[15:11]},sel);
	mux m12(q[12],{12'b0,in[15:12]},sel);
	mux m13(q[13],{13'b0,in[15:13]},sel);
	mux m14(q[14],{14'b0,in[15:14]},sel);
	mux m15(q[15],{15'b0,in[15]},sel);
endmodule

module sar_barrel_shifter(q,in,sel);
	output [15:0]q;
	input [15:0]in;
	input[3:0]sel;
	mux m0(q[0],in,sel);
	mux m1(q[1],{in[15],in[15:1]},sel);
	mux m2(q[2],{{2{in[15]}},in[15:2]},sel);
	mux m3(q[3],{{3{in[15]}},in[15:3]},sel);
	mux m4(q[4],{{4{in[15]}},in[15:4]},sel);
	mux m5(q[5],{{5{in[15]}},in[15:5]},sel);
	mux m6(q[6],{{6{in[15]}},in[15:6]},sel);
	mux m7(q[7],{{7{in[15]}},in[15:7]},sel);
	mux m8(q[8],{{8{in[15]}},in[15:8]},sel);
	mux m9(q[9],{{9{in[15]}},in[15:9]},sel);
	mux m10(q[10],{{10{in[15]}},in[15:10]},sel);
	mux m11(q[11],{{11{in[15]}},in[15:11]},sel);
	mux m12(q[12],{{12{in[15]}},in[15:12]},sel);
	mux m13(q[13],{{13{in[15]}},in[15:13]},sel);
	mux m14(q[14],{{14{in[15]}},in[15:14]},sel);
	mux m15(q[15],{{15{in[15]}},in[15]},sel);
endmodule


module sll_barrel_shifter(q,in,sel);
	output [15:0]q;
	input [15:0]in;
	input[3:0]sel;
	l_mux m0(q[0],{in[0],15'b0},sel);
	l_mux m1(q[1],{in[1:0],14'b0},sel);
	l_mux m2(q[2],{in[2:0],13'b0},sel);
	l_mux m3(q[3],{in[3:0],12'b0},sel);
	l_mux m4(q[4],{in[4:0],11'b0},sel);
	l_mux m5(q[5],{in[5:0],10'b0},sel);
	l_mux m6(q[6],{in[6:0],9'b0},sel);
	l_mux m7(q[7],{in[7:0],8'b0},sel);
	l_mux m8(q[8],{in[8:0],7'b0},sel);
	l_mux m9(q[9],{in[9:0],6'b0},sel);
	l_mux m10(q[10],{in[10:0],5'b0},sel);
	l_mux m11(q[11],{in[11:0],4'b0},sel);
	l_mux m12(q[12],{in[12:0],3'b0},sel);
	l_mux m13(q[13],{in[13:0],2'b0},sel);
	l_mux m14(q[14],{in[14:0],1'b0},sel);
	l_mux m15(q[15],in,sel);
endmodule


module l_mux(y,in,sel);
	input[15:0]in;
	output y;
	reg y;
	input [3:0]sel;
	always @(sel) begin
		if (sel==4'd0)
			y = in[15];
		else if (sel==4'd1)
			y = in[14];
		else if (sel==4'd2)
			y = in[13];
		else if (sel==4'd3)
			y = in[12];
		else if (sel==4'd4)
			y = in[11];
		else if (sel==4'd5)
			y = in[10];
		else if (sel==4'd6)
			y = in[9];
		else if (sel==4'd7)
			y = in[8];
		else if (sel==4'd8)
			y = in[7];
		else if (sel==4'd9)
			y = in[6];
		else if (sel==4'd10)
			y = in[5];
		else if (sel==4'd11)
			y = in[4];
		else if (sel==4'd12)
			y = in[3];
		else if (sel==4'd13)
			y = in[2];
		else if (sel==4'd14)
			y = in[1];
		else if (sel==4'd15)
			y = in[0];
    end
  endmodule
  
  
module mux(y,in,sel);
	input[15:0]in;
	output y;
	reg y;
	input [3:0]sel;
	always @(sel) begin
		if (sel==4'd0)
			y = in[0];
		else if (sel==4'd1)
			y = in[1];
		else if (sel==4'd2)
			y = in[2];
		else if (sel==4'd3)
			y = in[3];
		else if (sel==4'd4)
			y = in[4];
		else if (sel==4'd5)
			y = in[5];
		else if (sel==4'd6)
			y = in[6];
		else if (sel==4'd7)
			y = in[7];
		else if (sel==4'd8)
			y = in[8];
		else if (sel==4'd9)
			y = in[9];
		else if (sel==4'd10)
			y = in[10];
		else if (sel==4'd11)
			y = in[11];
		else if (sel==4'd12)
			y = in[12];
		else if (sel==4'd13)
			y = in[13];
		else if (sel==4'd14)
			y = in[14];
		else if (sel==4'd15)
			y = in[15];
    end
 endmodule
  

module data_mem(data_reg, dm_read, dm_wr, addr, wr_data);
input dm_read;
input dm_wr;
input [15:0] addr;
input [15:0] wr_data;
output reg [15:0] data_reg;
reg [7:0] memory [65535:0];

always @(posedge dm_wr)
begin
	{memory[addr+1], memory[addr]} = wr_data;
end

always @(posedge dm_read) begin
	data_reg = {memory[addr+1], memory[addr]};
end
endmodule

module instr_mem(instr_reg,im_read,pc);
output reg [15:0] instr_reg;
input im_read;
input [15:0] pc;
reg [7:0] memory [65535:0];

always @(posedge im_read) begin
    instr_reg[15:8] = memory[pc+1];
    instr_reg[7:0] = memory[pc];
end


initial begin
	/*HARDCODED*/
	//Instructions are hard coded here. Since we couldn't update PC properly only first one or two in some cases can be run continuously.
    {memory[1],memory[0]} = 16'b0000100101000010;
    {memory[3],memory[2]} = 16'b1010001100010000;
    
end
endmodule


//Reg File starts here
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
	/*HARDCODED*/
	registers[12] = 16'h1111;
    registers[9] = 16'h8f00;
    registers[1] = 16'h1010;
	registers[3] = 16'h0005;
end
endmodule


//ALU Control starts here
module alu_control (
    output [2:0] alu_ctrl,
    input [3:0] op,
    input [3:0] func_field
);

    wire select = |op;
    assign alu_ctrl[2] = select ? op[2] | (op[3] & op[1] & op[0]) : 1'b0;
    assign alu_ctrl[1] = select ? ~op[2] | (~op[3] & op[1] & op[0]) : func_field[1] & func_field[0];
    assign alu_ctrl[0] = select ? (~op[2] & (~op[3] | ~op[1] | ~op[0])) | (~op[3] & op[1] & ~op[0]) | (&op) : ~func_field[0];
endmodule

//PC starts here
module pc (
    output reg [15:0]pcreg,
    input [15:0]aluout,
    input [15:0] read_data_c,
    input PCSel, input PCcombined
);
    always @(posedge PCcombined) begin
        if(PCSel == 1'b1)
            pcreg = read_data_c;
        else
            pcreg = aluout;
    end
endmodule


//4:1 Mux
module mux_4to1_4bit(
    output [3:0] out,
    input [3:0] a, 
    input [3:0] b, 
    input [3:0] c,
    input [3:0] d,               
    input [1:0] sel             
);             
  
   assign out = sel[1] ? (sel[0] ? d : c) : (sel[0] ? b : a);    
endmodule 

//2:1 Mux
module mux_2to1_16bit(
    output [15:0] out,
    input [15:0] a, 
    input [15:0] b, 
    input sel 
);
assign out = sel ? b : a;  
endmodule

/*
module tb_alu_control;
    wire [2:0] alu;
    reg [3:0] opcode, ff;
    
    alu_control a1(alu, opcode, ff);
    initial begin
        opcode = 4'b0000;
        ff = 4'h1;
        repeat(2)
            #1 ff = ff + 1;
        #1 ff = 4'bxxxx;
        repeat(15)
            #1 opcode = opcode + 1;
    end

    initial begin
        $monitor("op = %b, ALU_Control = %b", opcode, alu);
        #20 $finish;
    end
endmodule
*/

/*
module tb_alu;
wire [15:0]ALUOut;
wire zero_flag;
reg [15:0]SrcA,SrcB;
reg [2:0]ALUCtrl;

main_ALU a1(ALUOut, zero_flag, SrcA, SrcB, ALUCtrl);

initial begin
    SrcA = 16'h70FF;//16'b1100_1100_1100_1100;
	SrcB = 16'h000F;//16'b0110_0110_0110_0110;
    ALUCtrl = 3'b010;
end

initial begin
    $display("A = %b, B = %b", SrcA, SrcB);
    #1 $display("ALUOut = %b, zero_flag = %b", ALUOut, zero_flag);
end
endmodule
*/

/*
module tb_control;
wire PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src;
wire[1:0] PC_Wr_Cond;
wire [1:0] ALU_Src_A;
wire [2:0] ALU_Src_B;
wire [1:0] RegA_Sel;
wire RegC_Sel;
reg [3:0] opcode;
reg clk;
wire [3:0] p_state, n_state;
wire opcode_flag;

control c1(PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, RegA_Sel, RegC_Sel, opcode, clk, p_state, n_state, opcode_flag);
initial begin
    opcode = 4'hF;
    clk = 1'b1; 
end
initial begin
    forever #1 clk = ~clk;        
end
initial begin 
    // $display("PC_Sel = %b, PC_Wr = %b, IM_Read = %b, DM_Read = %b, DM_Wr = %b,\n Reg_Dst = %b, Mem_to_Reg = %b, Reg_Wr = %b, Data_Src = %b, PC_Wr_Cond = %b,\n ALU_Src_A = %b, ALU_Src_B = %b, opcode = %b, clk = %b, p_state = %b, n_state = %b, opcode_flag",PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, opcode, clk, p_state, n_state, opcode_flag);
    // $display("\n");
    // repeat(16) begin
    #2 $display("PC_Sel = %b, PC_Wr = %b, IM_Read = %b, DM_Read = %b, DM_Wr = %b,\n Reg_Dst = %b, Mem_to_Reg = %b, Reg_Wr = %b, Data_Src = %b, PC_Wr_Cond = %b,\n ALU_Src_A = %b, ALU_Src_B = %b, opcode = %b, clk = %b, p_state = %b, n_state = %b, opcode_flag",PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, opcode, clk, p_state, n_state, opcode_flag);
    $display("\n");
    #2 $display("PC_Sel = %b, PC_Wr = %b, IM_Read = %b, DM_Read = %b, DM_Wr = %b,\n Reg_Dst = %b, Mem_to_Reg = %b, Reg_Wr = %b, Data_Src = %b, PC_Wr_Cond = %b,\n ALU_Src_A = %b, ALU_Src_B = %b, opcode = %b, clk = %b, p_state = %b, n_state = %b, opcode_flag",PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, opcode, clk, p_state, n_state, opcode_flag);
    $display("\n");
    #2 $display("PC_Sel = %b, PC_Wr = %b, IM_Read = %b, DM_Read = %b, DM_Wr = %b,\n Reg_Dst = %b, Mem_to_Reg = %b, Reg_Wr = %b, Data_Src = %b, PC_Wr_Cond = %b,\n ALU_Src_A = %b, ALU_Src_B = %b, opcode = %b, clk = %b, p_state = %b, n_state = %b, opcode_flag",PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, opcode, clk, p_state, n_state, opcode_flag);
    $display("\n");
    #2 $display("PC_Sel = %b, PC_Wr = %b, IM_Read = %b, DM_Read = %b, DM_Wr = %b,\n Reg_Dst = %b, Mem_to_Reg = %b, Reg_Wr = %b, Data_Src = %b, PC_Wr_Cond = %b,\n ALU_Src_A = %b, ALU_Src_B = %b, opcode = %b, clk = %b, p_state = %b, n_state = %b, opcode_flag",PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, opcode, clk, p_state, n_state, opcode_flag);
    $display("\n");
    #2 $display("PC_Sel = %b, PC_Wr = %b, IM_Read = %b, DM_Read = %b, DM_Wr = %b,\n Reg_Dst = %b, Mem_to_Reg = %b, Reg_Wr = %b, Data_Src = %b, PC_Wr_Cond = %b,\n ALU_Src_A = %b, ALU_Src_B = %b, opcode = %b, clk = %b, p_state = %b, n_state = %b, opcode_flag",PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, opcode, clk, p_state, n_state, opcode_flag);
    $display("\n----------------------------------------------------------------------------------");
    // opcode = opcode + 1;
    // end

end

// initial begin
//     $monitor($time, " P = %b, N = %b, C = %b", p_state, n_state, clk);
// end
initial begin
    #11 $finish;
end
endmodule

// initial begin
//     $display("P = %b, N = %b, O = %b %b clk %b\n", p_state, n_state, opcode, opcode_flag, clk);
//     #1 $display("P = %b, N = %b, O = %b %b clk %b\n", p_state, n_state, opcode, opcode_flag, clk);
//     #1 $display("P = %b, N = %b, O = %b %b clk %b\n", p_state, n_state, opcode, opcode_flag, clk);
//     #1 $display("P = %b, N = %b, O = %b %b clk %b\n", p_state, n_state, opcode, opcode_flag, clk);
//     #1 $display("P = %b, N = %b, O = %b %b clk %b\n", p_state, n_state, opcode, opcode_flag, clk);
//     #1 $display("P = %b, N = %b, O = %b %b clk %b\n", p_state, n_state, opcode, opcode_flag, clk);
//     #1 $display("P = %b, N = %b, O = %b %b clk %b\n", p_state, n_state, opcode, opcode_flag, clk);
//     #1 $display("P = %b, N = %b, O = %b %b clk %b\n", p_state, n_state, opcode, opcode_flag, clk);
//     #1 $display("P = %b, N = %b, O = %b %b clk %b\n", p_state, n_state, opcode, opcode_flag, clk);
//     #1 $display("P = %b, N = %b, O = %b %b clk %b\n", p_state, n_state, opcode, opcode_flag, clk);
//     #1 $display("P = %b, N = %b, O = %b %b clk %b\n", p_state, n_state, opcode, opcode_flag, clk);
//     #1 $display("P = %b, N = %b, O = %b %b clk %b\n", p_state, n_state, opcode, opcode_flag, clk);

// end
*/

/*
module tb_pc;
wire [15:0]pcreg;
reg [15:0]aluout;
reg [15:0] read_data_c;
reg PCSel; reg PCcombined;

pc p1(pcreg, aluout, read_data_c, PCSel, PCcombined);

initial begin
    PCcombined = 1'b0; PCSel = 0; aluout = 16'b0; read_data_c = 16'hffff;
    #1 PCSel = 1'b1; PCcombined = 1'b1;
end
initial begin
    $monitor($time, " PC_Sel = %b, aluout = %b, PCcomb = %b, pcreg = %b", PCSel, aluout, PCcombined, pcreg);
end
endmodule
*/

/*
module tb_im;
wire [15:0] instr_reg;
reg im_read;
reg [15:0] pc;
instr_mem i1(instr_reg, im_read, pc);

initial begin
    pc = 16'b0;
    im_read = 1'b0;
    #2 im_read = 1'b1;
    #1 pc = pc+16'h0002;
    im_read = 1'b0;
    #1 im_read = 1'b1;
end
initial begin
    $monitor($time, " ireg = %b", instr_reg);
end
endmodule
*/