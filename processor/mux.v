module mux_4to1_assign(
    output [3:0] out,
    input [3:0] a, 
    input [3:0] b, 
    input [3:0] c,
    input [3:0] d,               
    input [1:0] sel             
);             
  
   assign out = sel[1] ? (sel[0] ? d : c) : (sel[0] ? b : a);  

  
endmodule

// module mux_4to1_16(
//     output [15:0] out,
//     input [15:0] a, 
//     input [15:0] b, 
//     input [15:0] c,
//     input [15:0] d,               
//     input [1:0] sel             
// );             
  
//    assign out = sel[1] ? (sel[0] ? d : c) : (sel[0] ? b : a);  

  
// endmodule

module mux_2to1_16bit(
    output [15:0] out,
    input [15:0] a, 
    input [15:0] b, 
    input sel 
);
assign out = sel ? b : a;  
endmodule


