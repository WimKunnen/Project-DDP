`timescale 1ns / 1ps

module adder(
    input  wire          clk,
    input  wire          resetn,
    input  wire          start,
    input  wire          subtract,
    input  wire          shift,
    input  wire [1027:0] in_a,
    input  wire [1027:0] in_b,
    output wire [1028:0] result,
    output wire          done    
    );

    assign result = in_a + in_b;

    assign done = 1'b1;

endmodule