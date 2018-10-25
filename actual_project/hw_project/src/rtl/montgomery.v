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
 
    // Intance of 1027 bit adder module.
    reg adder_resetn;
    reg adder_start;
    reg adder_subtract;
    wire [1026:0] adder_input_a;
    wire [1026:0] adder_input_b;
    wire [1027:0] adder_result;
    wire adder_done;
    
    mpadder adder(
         .clk(clk),
         .resetn(adder_resetn),
         .start(adder_start),
         .subtract(adder_subtract),
         .in_a(adder_input_a),
         .in_b(adder_input_b),
         .result(adder_result),
         .done(adder_done)    
         );
         
         
    // Next c multiplexer
    wire [1027:0] next_c; 
    
    // 1027 bit C register.
    reg [1027:0] c;
    always @(posedge clk)
    begin
        c <= next_c;
    end 
    /*
    Student tasks:
    1. Instantiate an Adder -> done
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

    assign done = 1;
endmodule