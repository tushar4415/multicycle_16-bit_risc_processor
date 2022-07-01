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
    output reg [1:0]PC_Wr_Cond,
    output reg [1:0] ALU_Src_A,
    output reg [2:0] ALU_Src_B,
    output reg [1:0] RegA_Sel,
    output reg RegC_Sel,
    output reg csig,
    input [3:0] opcode,
    input clk,
    output reg [3:0] p_state,    
    output reg [3:0] n_state,
    output reg opcode_flag
    );

    // reg [3:0] p_state, n_state
    // reg opcode_flag;
    // reg opcode;
    initial begin
        p_state = 4'b0000;
        //n_state = 4'b0001;
        opcode_flag = 1'b0;
    end
    
    always @(negedge clk) begin
        case (p_state)
            4'h0: begin
                    PC_Sel = 1'b0; PC_Wr = 1'b1; IM_Read = 1'b1; DM_Read = 1'b0;
                    DM_Wr = 1'b0; Reg_Dst = 1'b0; Mem_to_Reg = 1'b0; Reg_Wr = 1'b0;
                    Data_Src = 1'b1; PC_Wr_Cond = 2'b0; ALU_Src_A = 2'b00; ALU_Src_B = 3'b001;
                    p_state = 4'h1;
                    RegA_Sel = 2'b0;
                    RegC_Sel = 1'b0;  
                    opcode_flag = 1'b1;
                  end
            4'h1: begin
                    PC_Wr = 1'b0; IM_Read = 1'b0;
                    p_state = n_state;
                  end
            4'h2: begin
                    csig = 1'b0;                  
                    ALU_Src_A = 2'b10; ALU_Src_B = 3'b110;
                    p_state = 4'hA;
                    RegA_Sel = 2'b01;
                    RegC_Sel = 1'b0;
                  end
            4'h3: begin
                    csig = 1'b0;                  
                    ALU_Src_A = 2'b11; ALU_Src_B = 3'b101;
                    p_state = 4'hB;
                    RegA_Sel = 2'b10;
                    RegC_Sel = 1'b1;
                  end
            4'h4: begin
                    ALU_Src_A = 2'b00; ALU_Src_B = 3'b010; PC_Wr = 1'b1;
                    csig = 1'b0;                  
                    p_state = 4'h0;
                  end
            4'h5: begin
                    PC_Wr_Cond = 2'b11; PC_Sel = 1'b1; ALU_Src_A = 2'b01; ALU_Src_B = 4'b0;
                    p_state = 4'h0;
                    csig = 1'b0;                  
                    ALU_Src_A = 2'b00; ALU_Src_B = 3'b001;
                  end
            4'h6: begin
                    PC_Wr_Cond = 2'b10; PC_Sel = 1'b1; ALU_Src_A = 2'b01; ALU_Src_B = 4'b0;
                    csig = 1'b0;                  
                    p_state = 4'h0;
                    ALU_Src_A = 2'b00; ALU_Src_B = 3'b001;
                  end
            4'h7: begin
                    ALU_Src_A = 2'b10; ALU_Src_B = 3'b011;
                    csig = 1'b0;                  
                    p_state = 4'hA;
                    RegA_Sel = 2'b01;
                    RegC_Sel = 1'b0;
                  end
            4'h8: begin
                    ALU_Src_A = 2'b01; ALU_Src_B = 3'b0;
                    csig = 1'b0;                  
                    p_state = 4'hA;
                  end
            4'h9: begin
                    ALU_Src_A = 2'b10; ALU_Src_B = 3'b100;
                    csig = 1'b0;                  
                    p_state = 4'hA;
                    RegA_Sel = 2'b01;
                    RegC_Sel = 1'b0;
                  end
            
            4'hA: begin
                    Mem_to_Reg = 1'b1; Reg_Dst = 1'b0; Reg_Wr = 1'b1;
                    p_state = 4'h0;
                    ALU_Src_A = 2'b00; ALU_Src_B = 3'b001;

                  end
            4'hB: begin
                    DM_Read = 1'b1; DM_Wr = 1'b0;
                    p_state = 4'hD;
                  end
            4'hC: begin
                    Data_Src = 1'b0; DM_Wr = 1'b1; DM_Read = 1'b0;
                    p_state = 4'h0;
                    ALU_Src_A = 2'b00; ALU_Src_B = 3'b001;
                  end
            4'hD: begin
                    Reg_Dst = 1'b1; Mem_to_Reg = 1'b0; Reg_Wr = 1'b1;
                    p_state = 4'h0;
                    ALU_Src_A = 2'b00; ALU_Src_B = 3'b001;
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
            default: n_state = 4'h0;    // Find better default.
        endcase
        opcode_flag = 1'b0;
    end
    // always @(n_state) begin
    //     opcode_flag = 1'b0;
    // end

endmodule