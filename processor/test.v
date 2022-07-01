module test;
reg [5:0] cnt1, cnt2;
reg clk;
reg [5:0] rega, regb, sub;
initial begin
    cnt1 = 5'b0; cnt2 = 5'b0;
    forever begin #1 cnt1 = cnt1 + 1'b1; cnt2 = cnt2 + 5'h05; end
end
initial begin
    clk = 1'b0;
    forever #1 clk = ~clk;
end
// always @(posedge clk) begin
//     rega <= cnt1;
//     regb <= cnt2;
// end
always @(posedge clk) begin
    // sub = regb-rega;
    sub = cnt2-cnt1;
end
initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, test);
end
initial #10 $finish;

endmodule