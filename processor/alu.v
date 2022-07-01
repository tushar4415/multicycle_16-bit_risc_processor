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
			//sixteenbitadder s1(ALUOut,carry_out,SrcA,SrcB,0);
			ALUOut = temp_outA;
			cin = 0;
			/*
			if(~|(ALUOut))
				zero_flag = 1'b1;
			else
				zero_flag = 1'b0;
			*/
		end
		
		//sub
		3'b100:
		begin
			//sixteenbitadder s1(ALUOut,carry_out,SrcA,~(SrcB),1);
			ALUOut = temp_outA;
			cin = 1;
			/*
			if(~|(ALUOut))
				zero_flag = 1'b1;
			else
				zero_flag = 1'b0;
			*/
		end
		
		//or
		3'b101:
		begin
			//sixteenbitor o1(ALUOut,SrcA,SrcB);
			ALUOut = temp_outB;
		end
		
		//nand
		3'b110:
		begin
			//sixteenbitnand n1(ALUOut,SrcA,SrcB);
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
	//assign Sum = A+B+cin;
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
  
 
/*module tb_barrel_shifter;
	wire [15:0]op_t,q_t;
	reg [15:0]ip_t;
	reg [3:0]S_t;
	slr_barrel_shifter b1(op_t, ip_t, S_t);
	initial begin
		ip_t = 16'b0;
		S_t = 4'd0;
		#5ip_t = 16'hFFFF;
		S_t = 4'd2;
	end
	
	initial begin
		$monitor($time," ip_t = %b, %d, op_t = %b, %d, S_t = %d",ip_t, ip_t, op_t, op_t, S_t);
	end
endmodule
*/

// module tb_alu;
// wire [15:0]ALUOut;
// wire zero_flag;
// reg [15:0]SrcA,SrcB;
// reg [2:0]ALUCtrl;

// main_ALU a1(ALUOut, zero_flag, SrcA, SrcB, ALUCtrl);

// initial begin
//     SrcA = 16'h70FF;//16'b1100_1100_1100_1100;
// 	SrcB = 16'h0005;//16'b0110_0110_0110_0110;
//     ALUCtrl = 3'b010;
// end

// initial begin
//     $display("A = %b, B = %b", SrcA, SrcB);
//     #1 $display("ALUOut = %b, zero_flag = %b", ALUOut, zero_flag);
// end
// endmodule