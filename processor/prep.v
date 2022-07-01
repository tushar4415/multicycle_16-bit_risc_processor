module instruct_mem(ir, pc_in, pc_wr1, pc, clk, instr_wr, instr_in);//Instruction memory 
    output reg[15:0]ir;                                             //With Instruction register 
    output reg[15:0]pc;                                             //And program counter

    input clk;
    input instr_wr;
    input pc_wr1;

    input [15:0]instr_in;
    input [15:0]pc_in;

    reg [7:0]mem_even[0:32767]; //Stored in little endian format
    reg [7:0]mem_odd[0:32767];  //With even and odd banks

    wire [14:0]address;

    assign address = pc[15:1];

    always @(posedge clk) begin
        if(pc_wr1)
            pc <= pc_in;
        if(!instr_wr)
            ir <= {mem_odd[address], mem_even[address]};
        else begin                      //exists for the express purpose of initialisation
            ir <= 16'hzzzz;
            mem_even[address] <= instr_in[7:0];
            mem_odd[address] <= instr_in[15:8];
        end
    end
endmodule
/*
module PC(pc, clk, pc_wr1, pc_in);   //Program counter register
    output reg[15:0]pc;

    input clk;
    input pc_wr1;
    input [15:0]pc_in;

    always @(posedge clk ) begin
        if(pc_wr1)
            pc <= pc_in;
    end
endmodule

module IR(ir, clk, ir_in);          //Instruction register
    output [15:0]ir;

    input clk;
    input [15:0]ir_in;

    reg [15:0]IR;

    assign ir = IR;

    always @(posedge clk ) begin
        IR <= ir_in;
    end
endmodule
*/
module mux_reg_A(rn1, regA, ir7_4, ir11_8); //Mux before RN1
    output [3:0]rn1;    //First read register address in reg_file 

    input [3:0]ir7_4; // IR[7:4]
    input [3:0]ir11_8; // IR[11:8]

    input [1:0]regA;  //RegA

    assign rn1 = regA[1] ? (!regA[0] ? {2'b10, ir11_8[1:0]} : 4'hz) : (regA[0] ? ir11_8 : ir7_4);
endmodule

module mux_reg_B(rn2, in0, in1, regB);    //Mux before RN2
    output [3:0]rn2;    //Second read register address in reg_file

    input [3:0]in0; // IR[3:0]
    input [3:0]in1; // {2'b11, IR[11:10]} 

    input regB;   //RegB

    assign rn2 = regB ? in1 : in0;
endmodule

module mux_reg_dst(wr, ir11_8, reg_dst);
    output [3:0]wr; //Write register address in reg_file

    input [3:0]ir11_8; //ir[11:8]

    input reg_dst;

    assign wr = reg_dst ? {2'b11, ir11_8[2:1]} : ir11_8;
endmodule

module reg_file(A, B, C, rn1, rn2, rn3, read3, wr, wd,  reg_wr, clk);
    output reg [15:0]A;
    output reg [15:0]B;
    output reg [15:0]C;

    input [15:0]wd;

    input [3:0]rn1;
    input [3:0]rn2;
    input [3:0]rn3;

    input [3:0]wr;

    input clk;
    input reg_wr;
    input read3;

    reg [15:0]register_file[0:15];

    
    initial register_file[0] = 16'h0000; //$0 is hard coded to 0

    always @(posedge clk ) begin
        A <= register_file[rn1];
        B <= register_file[rn2];
        if(read3)                       //only true for Branch statement
            C <= register_file[rn3];
        if(reg_wr & (|wr))              //$0 is not valid write location
            register_file[wr] <= wd;
    end
endmodule

module sign_ext_8to16(out, in);
    output [15:0]out;
    input [7:0]in;

    assign out = {{8{in[7]}}, in[7:0]};
endmodule

module mux_alu_A(alu_A, pc, A, alu_srcA);
    output [15:0]alu_A;

    input [15:0]pc;
    input [15:0]A;

    input alu_srcA;

    assign alu_A = alu_srcA ? A : pc;
endmodule

module mux_alu_B(alu_B, ir11_0, B, alu_srcB); //send in ir[11:0]
    output [15:0]alu_B;
    
    input [11:0]ir11_0;                     //ir[11:0]
    input [15:0]B;
    input [2:0]alu_srcB;

    wire [15:0]ir_sign_ext;

    reg [15:0]alu_B1;

    sign_ext_8to16 U0(.out(ir_sign_ext), .in(ir11_0[7:0]));

    always @(*) begin
        case(alu_srcB)
        3'b000 : alu_B1 <= 16'h0002;
        3'b001 : alu_B1 <= B;
        3'b010 : alu_B1 <= ir_sign_ext;
        3'b011 : alu_B1 <= {8'h00, ir11_0[7:0]};
        3'b100 : alu_B1 <= (ir_sign_ext << 1);
        3'b101 : alu_B1 <= {4'h0, ir11_0};
        default: alu_B1 <= 16'hzzzz;
        endcase
    end

    assign alu_B = alu_B1;
endmodule

module shift_control(sh_op, opcode, ffield);    
    output [1:0]sh_op;

    input [3:0]opcode;  //opcode = ir[15:12]
    input [3:0]ffield;  //ffield = ir[3:0] , ffield is function field

    assign sh_op = (~(|opcode)) ? ffield[1:0] : 2'b00;
endmodule

module mux_alu_out(alu_out, alu, shifter, output_cont, clk); 
    output reg [15:0]alu_out;

    input [15:0]alu;
    input [15:0]shifter;

    input clk;
    input output_cont; //output control signal

    wire [15:0]out;

    assign out = output_cont ? shifter : alu;

    always @(posedge clk ) begin
        alu_out <= out;
    end
endmodule

module mux_pc_src(pc_in, pc_src, alu, C);
    output [15:0]pc_in;

    input [15:0]alu;
    input [15:0]C;

    input pc_src;

    assign pc_in = pc_src ? C : alu;
endmodule

module data_mem(mdr, addr, data_in, memr, memw, clk);
    output [15:0]mdr;

    input [15:0]addr;   //input address is always even!!
                        //Comes from alu_out register

    input memr;         //Memory read condition
    input memw;         //Memory write condition
    input clk;
    input [15:0]data_in;

    reg [7:0]mem_even[0:32767];
    reg [7:0]mem_odd[0:32767];

    reg [15:0]wd1;

    wire [14:0]address;

    assign address = addr[15:1];
    assign mdr = wd1;

    always @(posedge clk) begin
        if(memr&(!memw))
            wd1 <= {mem_odd[address], mem_even[address]};
        else if(memw&(!memr)) begin
            mem_even[address] <= data_in[7:0];
            mem_odd[address] <= data_in[15:8];
        end
    end
endmodule

module mux_mem_to_reg(wd, alu_out, mdr, mem_to_reg);
    output [15:0]wd;

    input [15:0]mdr;
    input [15:0]alu_out;
    input mem_to_reg;

    assign wd = mem_to_reg ? mdr : alu_out;
endmodule

module pc_wr_control(pc_wr1, pc_wr, pc_src, eqb, zf);
    output pc_wr1;

    input pc_wr;
    input pc_src;
    input eqb;
    input zf;

    assign pc_wr1 = pc_wr | (pc_src & (eqb^zf));
endmodule

module data_path(   input   clk, 
                            pc_wr,
                            regB,
                            reg_dst,
                            read3,
                            reg_wr,
                            alu_srcA,
                            output_cont,
                            pc_src,
                            mem_to_reg,
                            eqb,
                            instr_wr,

                    input [1:0] regA,
                                alu_op,
                    
                    input [2:0] alu_srcB,

                    input [15:0] instr_in,

                    output [15:0]   pc, 
                                    A,
                                    B,
                                    C,
                                    mdr, 
                                    alu_out,
                                    ir);
    
    wire [15:0]pc_in;
    wire pc_wr1;
    wire zf;            //Connect to ALU module zf output

    wire [3:0]rn1, rn2, rn3, wr;

    wire [1:0]sh_op;

    wire [15:0]wd;
    wire [15:0]ir_sign_ext;
    wire [15:0]alu_A, alu_B;    //Input A and B to ALU
    wire [15:0]alu;             //Output of ALU
    wire [15:0]shifter;         //Output of shifter

    assign rn3 = ir[11:8];

    pc_wr_control U0(.pc_wr1(pc_wr1), .pc_wr(pc_wr), .pc_src(pc_src), .eqb(eqb), .zf(zf));

    instruct_mem U1(.ir(ir), 
                    .pc(pc), 
                    .clk(clk), 
                    .instr_wr(instr_wr), 
                    .instr_in(instr_in),  
                    .pc_wr1(pc_wr1), 
                    .pc_in(pc_in));
    //ir, pc_in, pc_wr1, pc, clk, instr_wr, instr_in

    mux_reg_A U2(.rn1(rn1), .regA(regA), .ir7_4(ir[7:4]), .ir11_8(ir[11:8]));

    mux_reg_B U3(.rn2(rn2), .regB(regB), .in0(ir[3:0]), .in1({2'b11, ir[11:10]}));

    mux_reg_dst U4(.wr(wr), .ir11_8(ir[11:8]), .reg_dst(reg_dst));

    mux_mem_to_reg U5(.wd(wd), .alu_out(alu_out), .mdr(mdr));

    reg_file U6(    .A(A), 
                    .B(B), 
                    .C(C), 
                    .rn1(rn1), 
                    .rn2(rn2), 
                    .rn3(rn3), 
                    .read3(read3), 
                    .wr(wr), 
                    .wd(wd),  
                    .reg_wr(reg_wr), 
                    .clk(clk));

    mux_alu_A U8(.alu_A(alu_A), .pc(pc), .A(A), .alu_srcA(alu_srcA));

    mux_alu_B U9(.alu_B(alu_B), .ir11_0(ir[11:0]), .B(B), .alu_srcB(alu_srcB));

    ALU U10(.alu(alu), .zf(zf), .alu_A(alu_A), .alu_B(alu_B), .alu_op(alu_op));

    shift_control U11(.sh_op(sh_op), .opcode(ir[15:12]), .ffield(ir[3:0]));

    //Shifter u12

    mux_alu_out U13(.alu_out(alu_out), 
                    .alu(alu), 
                    .shifter(shifter), 
                    .output_cont(output_cont), 
                    .clk);

    mux_pc_src U14(.pc_in(pc_in), .pc_src(pc_src), .alu(alu), .C(C));

    data_mem U15(.mdr(mdr), .addr(alu_out), .data_in(B), .memr(memr), .memw(memw), .clk(clk));

    mux_mem_to_reg U16(.wd(wd), .alu_out(alu_out), .mdr(mdr), .mem_to_reg(mem_to_reg));
endmodule

module ALU(alu, zf,alu_A, alu_B, alu_op);
    output [15:0]alu;
    output zf;

    input [15:0]alu_A, alu_B;
    input [1:0]alu_op;

    wire [15:0]alu_addsub;
    wire [15:0]alu_nand;
    wire [15:0]alu_or;

    wire [15:0]alu_B2;

    wire sign_B;

    assign sign_B = ((~(|alu_op))&(alu_B[15])) | (((~alu_op[1])&alu_op[0])&(~alu_B[15]));

    assign alu_B2 = ({{15{sign_B}}})^(alu_B) + {15'h0000, sign_B};

    assign alu_addsub = alu_A + alu_B2;

    assign alu_nand = ~(alu_A & alu_B);

    assign alu_or = (alu_A | alu_B);

    assign alu = alu_op[1] ? (alu_op[0] ? alu_or : alu_nand) : alu_addsub;

    assign zf = ~(|alu);
endmodule

