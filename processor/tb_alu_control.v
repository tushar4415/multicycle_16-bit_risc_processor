`include "alu_control.v"
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