module alu_control (
    output [2:0] alu_ctrl,
    input [3:0] op,
    input [3:0] func_field,
    input csig
);

    wire select = |op;

    assign alu_ctrl[2] = csig ? 1'b0 :(select ? op[2] | (op[3] & op[1] & op[0]) : 1'b0);
    assign alu_ctrl[1] = csig ? 1'b1 : (select ? ~op[2] | (~op[3] & op[1] & op[0]) : func_field[1] & func_field[0]);
    assign alu_ctrl[0] = csig ? 1'b1 : (select ? (~op[2] & (~op[3] | ~op[1] | ~op[0])) | (~op[3] & op[1] & ~op[0]) | (&op) : ~func_field[0]);
endmodule