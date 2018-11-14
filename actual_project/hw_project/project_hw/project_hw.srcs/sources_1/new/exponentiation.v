`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KU Leuven
// Engineer: Wim Kunnen
// 
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module exponentiation(
    input  wire          clk,
    input  wire          resetn,
    input  wire          start,
    input  wire [1023:0] in_x,
    input  wire [1023:0] in_r,
    input  wire [1023:0] in_r2,
    input  wire [1023:0] in_m,
    input  wire [1023:0] in_e,
    input  wire [1023:0] in_t,
    output wire [1023:0] result,
    output wire          done
    );
    
    
    // Intances of 1027 bit adder/subtracter module.
    reg mont_resetn;
    reg mont_start;
    reg mont_subtract;
    wire [1026:0] mont_input_a;
    wire [1026:0] mont_input_b;
    wire [1027:0] montesult;
    wire adder_done;
    
    montgomery mont(
         .clk      (clk           ),
         .resetn   (mont_resetn   ),
         .start    (mont_start    ),
         .subtract (mont_subtract ),
         .in_a     (mont_input_a  ),
         .in_b     (mont_input_b  ),
         .in_m     (mont_input_m  ),
         .result   (mont_result   ),
         .done     (mont_done     )
       );
    
    assign mont_input_m = in_m;
    
    reg [1023:0] r2;
    reg [1023:0] a;
    reg [1023:0] x_tilde;
    reg [1023:0] e;
    reg [1023:0] size;
    reg [1023:0] initial_size;
    reg loop;
    reg end_loop;
    reg [10:0] state;
    reg step;

    assign mont_input_a = (start == 1) ? in_x  : {a};
    assign mont_input_b = (loop == 0 ) ?  ( (end_loop ==0) ? in_r2 : {1024'b1} ) : ( (step == 0) ? {a} : {x_tilde} );
    assign in_t = (state == 10'b0) ? {in_t << 1} : {in_t-1}; 
    
    always @(posedge clk)
    begin
        size <= in_t;
        
        if (loop == 0)
        begin
            if (end_loop == 0)
            begin
                x_tilde <= mont_result;
                a       <= in_r; 
            end
            
            else
            begin
                a <= mont_result;
            end
        end
        
        else
        if (size != 1)
        begin
            if (e[0] == 1)
                a <= mont_result;
            else
                a <= a;
        end
    end
    
    
endmodule
