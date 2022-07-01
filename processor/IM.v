module instr_mem(instr_reg,im_read,pc);
output reg [15:0] instr_reg;
input im_read;
input [15:0] pc;
reg [7:0] memory [0:31];

always @(posedge im_read) begin
    instr_reg = {memory[pc+1], memory[pc]};
end


initial begin
    {memory[1], memory[0]} = 16'b1100001110010001;
    {memory[3], memory[2]} = 16'b0011000000000110;
    {memory[5], memory[4]} = 16'b1101001110010001;
    
end
endmodule

// module tbim;
// wire [15:0] instr_reg;
// reg im_read;
// reg [15:0] pc;
// instr_mem i1(instr_reg, im_read, pc);

// initial begin
//     pc = 16'b0;
//     im_read = 1'b0;
//     #2 im_read = 1'b1;
//     #1 pc = pc+16'h0002;
//     im_read = 1'b0;
//     #1 im_read = 1'b1;
// end
// initial begin
//     $monitor($time, " ireg = %b", instr_reg);
// end
// endmodule
