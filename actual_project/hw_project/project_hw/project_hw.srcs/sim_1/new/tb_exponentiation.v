`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2018 01:43:51 PM
// Design Name: 
// Module Name: tb_exponentiation
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.12 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_exponentiation();

    // Define internal regs and wires
    reg             clk;
    reg             resetn;
    reg             start;
    reg [1023:0]    in_x;
    reg [1023:0]    in_r;
    reg [1023:0]    in_r2;
    reg [1023:0]    in_m;
    reg [1023:0]    in_e;
    reg [9:0]    in_t;
    wire [1023:0]   result;
    wire            done;

    // Instantiating adder
    exponentiation dut (
        .clk        (clk),
        .resetn     (resetn),
        .start      (start),
        .in_x       (in_x),
        .in_r       (in_r),
        .in_r2      (in_r2),
        .in_m       (in_m),
        .in_e       (in_e),
        .in_t       (in_t),
        .result     (result),
        .done       (done));

    // Generate Clock
    initial begin
	//$dumpvars(0, tb_exponentiation);
        clk = 0;
        forever #`CLK_HALF clk = ~clk;
    end

    // Initialize signals to zero
    initial begin
        start   <= 0;
        in_x    <= 1023'h0;
        in_r    <= 1023'h0;
        in_r2   <= 1023'h0;
        in_m    <= 1023'h0;
        in_e    <= 1023'h0;
        in_t    <= 9'h0;
    end

    // Reset the circuit
    initial begin
        resetn = 0;
        #`RESET_TIME
        resetn = 1;
    end

    task perform_rsa;
//        input [1026:0] a;
//        input [1026:0] b;
//        begin
//            in_a <= a;
//            in_b <= b;
//            start <= 1'd1;
//            subtract <= 1'd0;
//            #`CLK_PERIOD;
//            start <= 1'd0;
//            wait (done==1);
//            #`CLK_PERIOD;
//        end
    endtask
    
//    wire [1023:0] reverse_e;
//    reg [1023:0] temp_e;
    
//    generate
//        genvar ii;
//        for (ii=1023; ii>=0; ii=ii-1)
//        begin
//            reverse_e[0] = 0;       
//        end
//    end
    
    reg [1023:0] expected;        
    initial begin
        expected <= 1024'h7b372b2b2b599c3521461a30464cba185022509950503acf41b533fd6a1762169561898acf750117c64a34a9636230792c33177d869e92069faf74ab35a49dead93a31a0dfa9686d24b05a1ae168dd21cf7ba14811f11e9d4552f3b697c3bb6becc40123c407e1a8fc0881b500df15472e8418d5e21eef405c80a5691e0fc16d;
        in_r <= 1024'h29355a906539830c6cd9674e3f9726dad01cb7c1ff1cc0c44f594905060da304dc8b62d53a25c7c485bab2ca7f9de7eb5faafb0126a1e7395070352bbf7f1bd5c3d2b7cd1fab735a0b74bb2a013d0cb5a1eca8b717cedc6d3ba09bbfb758659939bccc355930f30cec3b9e1b1fe812e9bf3021b19f890fbbf5c5a6917362f695;
        in_r2 <= 1024'hb243e11d7992baebf34d6b3b22cc7f79b9acc20c23ec8692a8c42e64d159463dc83e99b358878212e49ec9c2ef4f9c32bba05826df631a507a6121524d3d1914e1c771058a19b62773d9ea4e8dfaa74c5a36c8e0d696870f4f571f7ed5386a43fc50322897f5cb1ab4eda146b847decb284096240f456964447fe6d8e14a3049;
        in_m <= 1024'hd6caa56f9ac67cf3932698b1c068d9252fe3483e00e33f3bb0a6b6faf9f25cfb23749d2ac5da383b7a454d3580621814a05504fed95e18c6af8fcad44080e42a3c2d4832e0548ca5f48b44d5fec2f34a5e135748e8312392c45f644048a79a66c64333caa6cf0cf313c461e4e017ed1640cfde4e6076f0440a3a596e8c9d096b;
        in_e <= 1024'h904f;
        in_x <= 1024'ha3935ce177636f9ee4e64e8f247296b391dbeba9e29b81ba16396f5d83ea4414bc97ffdc39026a2371538811c3df998b5fed827baa5a032d723676eedb5dd43cf46405c28e6681c3229f74542040a7a025a4de17ca9980ea569fb01e3c4384f23ba7ca66aa85c7720d86e96905133c761fffb07f08e1b39e8649697d7a884221;
        in_t <= 9'h10;
        #`RESET_TIME
        start <= 1;
        #`CLK_PERIOD
        start <= 0;
        wait(done==1);
//        Dec exp      =  0x5a8ccf6f10984531baa72121e107032127601cfaf30008a7e1efcea315dfd3406db0819a755247122b8d18955574fdcf7d2850fdbf18c51653babb8ffad13f8eb0261ff039bfec365221520ae7d4a44f7595f951e4b8da7b8811685e651ef80b1108bb0efc6651b038e63f9168591f870383a7fd74fc43458e37691413acc649L
//        Plaintext    =  0xa3935ce177636f9ee4e64e8f247296b391dbeba9e29b81ba16396f5d83ea4414bc97ffdc39026a2371538811c3df998b5fed827baa5a032d723676eedb5dd43cf46405c28e6681c3229f74542040a7a025a4de17ca9980ea569fb01e3c4384f23ba7ca66aa85c7720d86e96905133c761fffb07f08e1b39e8649697d7a884221L
        
//        --- Execute RSA in HW (slow)
//        Ciphertext   =  0x7b372b2b2b599c3521461a30464cba185022509950503acf41b533fd6a1762169561898acf750117c64a34a9636230792c33177d869e92069faf74ab35a49dead93a31a0dfa9686d24b05a1ae168dd21cf7ba14811f11e9d4552f3b697c3bb6becc40123c407e1a8fc0881b500df15472e8418d5e21eef405c80a5691e0fc16dL
//        Plaintext    =  0xa3935ce177636f9ee4e64e8f247296b391dbeba9e29b81ba16396f5d83ea4414bc97ffdc39026a2371538811c3df998b5fed827baa5a032d723676eedb5dd43cf46405c28e6681c3229f74542040a7a025a4de17ca9980ea569fb01e3c4384f23ba7ca66aa85c7720d86e96905133c761fffb07f08e1b39e8649697d7a884221L

    end
    
    
endmodule
