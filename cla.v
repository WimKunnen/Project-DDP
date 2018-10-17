`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Yrjo
// 
// Create Date: 10/12/2018 12:40:26 PM
// Design Name: 
// Module Name: cla
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module full_adder 
  (
   input bit_one,
   input bit_two,
   input carry_in,
   output result,
   output carry_out
   );
 
  wire   in_or;
  wire   carry_or;
  wire   in_and;
       
  assign in_or = bit_one ^ bit_two;
  assign carry_or = in_or & carry_in;
  assign in_and = bit_one & bit_two;
  assign result   = in_or ^ carry_in;
  assign carry_out = carry_or | in_and;
endmodule

module cla(
    input [256:0] a,
    input [256:0] b,
    input carry_in,
    output [257:0] result
    );
    
    // Generate full adders.
    genvar i;
    generate
        for (i=0; i<257; i=i+1) begin : generate_full_adders // <-- example block name
            full_adder new_adder (
               .bit_one(a[i]),
               .bit_two(b[i]),
               .carry_in(carry[i]),
               .result(sum[i]),
               .carry_out()
                
            );
    end 
    endgenerate
    
    wire [256:0] carry_generate;
    wire [256:0] carry_propagate;
    wire [257:0] carry;
    wire [256:0] sum;
    
    assign carry_generate = a & b;
    assign carry_propagate = a | b;
    assign carry[0] = carry_in;
    assign carry[257:1] = carry_generate[256:0] | (carry_propagate[256:0] & carry[256:0]);
    assign result = {carry[257], sum};
endmodule
