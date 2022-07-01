`include "mux.v"
module tb_testmux2;
wire [15:0] out;
reg [15:0] a, b;
reg sel;

mux_2to1_16bit m1(out, a, b, sel);
initial begin
    $monitor($time, " out = %h, a = %h, b = %h", out, a, b);
end
initial begin
    a = 16'h1; b = 16'h2; sel = 1'b0;
    #2 sel = 16'b1;
end
endmodule