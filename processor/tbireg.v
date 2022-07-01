`include "datapath.v"
module tb_datapath;
// wire PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond;
// wire [1:0] ALU_Src_A;
// wire [2:0] ALU_Src_B;
// wire [3:0] opcode;
// reg clk;
// wire [3:0] p_state, n_state;
// wire opcode_flag;

// ireg r1(opcode, IM_Read);
// control c1(PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, opcode, clk, p_state, n_state, opcode_flag);

reg clk;
datapath d1(clk);
initial begin
    clk = 1'b1; 
end
initial begin
    forever #1 clk = ~clk;        
end
initial begin 
    // $display("PC_Sel = %b, PC_Wr = %b, IM_Read = %b, DM_Read = %b, DM_Wr = %b,\n Reg_Dst = %b, Mem_to_Reg = %b, Reg_Wr = %b, Data_Src = %b, PC_Wr_Cond = %b,\n ALU_Src_A = %b, ALU_Src_B = %b, opcode = %b, clk = %b, p_state = %b, n_state = %b, opcode_flag",PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, opcode, clk, p_state, n_state, opcode_flag);
    // $display("\n");
    // repeat(16) begin
    // #2 $display("PC_Sel = %b, PC_Wr = %b, IM_Read = %b, DM_Read = %b, DM_Wr = %b,\n Reg_Dst = %b, Mem_to_Reg = %b, Reg_Wr = %b, Data_Src = %b, PC_Wr_Cond = %b,\n ALU_Src_A = %b, ALU_Src_B = %b, opcode = %b, clk = %b, p_state = %b, n_state = %b, opcode_flag",PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, opcode, clk, p_state, n_state, opcode_flag);
    // $display("\n");
    // #2 $display("PC_Sel = %b, PC_Wr = %b, IM_Read = %b, DM_Read = %b, DM_Wr = %b,\n Reg_Dst = %b, Mem_to_Reg = %b, Reg_Wr = %b, Data_Src = %b, PC_Wr_Cond = %b,\n ALU_Src_A = %b, ALU_Src_B = %b, opcode = %b, clk = %b, p_state = %b, n_state = %b, opcode_flag",PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, opcode, clk, p_state, n_state, opcode_flag);
    // $display("\n");
    // #2 $display("PC_Sel = %b, PC_Wr = %b, IM_Read = %b, DM_Read = %b, DM_Wr = %b,\n Reg_Dst = %b, Mem_to_Reg = %b, Reg_Wr = %b, Data_Src = %b, PC_Wr_Cond = %b,\n ALU_Src_A = %b, ALU_Src_B = %b, opcode = %b, clk = %b, p_state = %b, n_state = %b, opcode_flag",PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, opcode, clk, p_state, n_state, opcode_flag);
    // $display("\n");
    // #2 $display("PC_Sel = %b, PC_Wr = %b, IM_Read = %b, DM_Read = %b, DM_Wr = %b,\n Reg_Dst = %b, Mem_to_Reg = %b, Reg_Wr = %b, Data_Src = %b, PC_Wr_Cond = %b,\n ALU_Src_A = %b, ALU_Src_B = %b, opcode = %b, clk = %b, p_state = %b, n_state = %b, opcode_flag",PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, opcode, clk, p_state, n_state, opcode_flag);
    // $display("\n");
    // #2 $display("PC_Sel = %b, PC_Wr = %b, IM_Read = %b, DM_Read = %b, DM_Wr = %b,\n Reg_Dst = %b, Mem_to_Reg = %b, Reg_Wr = %b, Data_Src = %b, PC_Wr_Cond = %b,\n ALU_Src_A = %b, ALU_Src_B = %b, opcode = %b, clk = %b, p_state = %b, n_state = %b, opcode_flag",PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, opcode, clk, p_state, n_state, opcode_flag);
    // $display("\n----------------------------------------------------------------------------------");
    // opcode = opcode + 1;
    // end

end

initial begin
    $monitor($time, " PC_Sel = %b, PC_Wr = %b, IM_Read = %b, DM_Read = %b, DM_Wr = %b,\n Reg_Dst = %b, Mem_to_Reg = %b, Reg_Wr = %b, Data_Src = %b, PC_Wr_Cond = %b,\n ALU_Src_A = %b, ALU_Src_B = %b, opcode = %b, p_state = %b\n",PC_Sel, PC_Wr, IM_Read, DM_Read, DM_Wr, Reg_Dst, Mem_to_Reg, Reg_Wr, Data_Src, PC_Wr_Cond, ALU_Src_A, ALU_Src_B, opcode, p_state);
end
initial begin
    #21 $finish;
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