module pc (
    output reg [15:0]pcreg,
    input [15:0]aluout,
    input [15:0] read_data_c,
    input PCSel, input PCcombined
);
    always @(posedge PCcombined) begin
        // if(PCcombined) begin
            if(PCSel == 1'b0)
                pcreg = aluout;
            else
                pcreg = read_data_c;
        // end        
    end
endmodule

// module tb_pc;
// wire [15:0]pcreg;
// reg [15:0]aluout;
// reg [15:0] read_data_c;
// reg PCSel; reg PCcombined;

// pc p1(pcreg, aluout, read_data_c, PCSel, PCcombined);

// initial begin
//     PCcombined = 1'b0; PCSel = 0; aluout = 16'b0; read_data_c = 16'hffff;
//     #1 PCSel = 1'b1; PCcombined = 1'b1;
// end
// initial begin
//     $monitor($time, " PC_Sel = %b, aluout = %b, PCcomb = %b, pcreg = %b", PCSel, aluout, PCcombined, pcreg);
// end
// endmodule