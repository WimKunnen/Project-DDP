`timescale 1ns / 1ps

module montgomery(
    input           clk,
    input           resetn,
    input           start,
    input  [1023:0] in_a,
    input  [1023:0] in_b,
    input  [1023:0] in_m,
    output [1023:0] result,  
    output          done
     );
 
    /*
    Student tasks:
    1. Instantiate an Adder
    2. Use the Adder to implement the Montgomery multiplier in hardware.
    3. Use tb_montgomery.v to simulate your design.
    */
    
    //This always block was added to ensure the tool doesn't trim away the montgomery module.
    //Students: Feel free to remove this block
    reg [1023:0] r_result;
    always @(posedge(clk))
    begin
        r_result <= {1024{1'b1}};
    end
    assign result = r_result;
    // ROFLMAO
    assign done = 1;
endmodule