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
    reg result_ok;
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
        in_t    <= 10'h0;
	result_ok <= 0;
    end

    // Reset the circuit
    initial begin
        resetn = 0;
        #`RESET_TIME
        resetn = 1;
    end
    
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
        in_t <= 10'h10;
        #`RESET_TIME
        start <= 1;
        #`CLK_PERIOD
        start <= 0;
        wait(done==1);
	result_ok <= (result == expected);
	#`CLK_PERIOD
	
	// Test with seed 2018.1
    // p            =  0xfd80487fb832db6ec4253c85e79446d81458ed4c19961031bc190db8060d4dca1ff8a52d795ebcd0770e0cf9ba4e0dc8e751a7a152557a0b5968c2ccee895953L
    // q            =  0xfcc62312fbd14327a70d448b8bcdb0183b94a6c368424b39a9316f922150325c2c950fba496dda7767555b95e82d0d9516eef83ccd36e8054c80abf745ac0623L
    //     Dec exp      =  0x5dafa8338cfd5e5c95bc1b8cf179c8c635e9f805dbb16d5782c6cc76d935467388465fb01df29f5123e1a1429b221e44ffdd2744bbcd5abae08e1cf99dac542a9e1b62182e288f95297971a79f243b05123ea753c7170d144bfd981365f0dd50a891a66781f93b8683063c6b1c78b4a1cc4a07fd7e58ca7d41b489001af386c3L
//    --- Execute RSA
//        Ciphertext   =  0x1c1f19b8a6bef4e86bf8574df7b576cfc8d2f79010eae22f0e4a6c11fa34def6dcc19b0204f3cfb17f8735d364aa2aec61b3d0015d5a17f6eb6008daf85af4c184eea3de7e0d87e2447a540cada80aca352c7cfac809b7257aa646005f1f3611846dc881c9e0bee49ce09f59fba086a60a86e8e183bd1d82bdafaea75d183991L
//        Plaintext    =  0xa4260ac649fc1f3c7799f4d803919d69de4f85cb2bbb7d355c1fd7c0c8f784c5cea64825c5b553502364fad4664037598de4da1147015c5e408dd53d633651148eace4141fa295a9c03a30ce9e1f2eb390f402a3a5a1dc715ca3c278a5830b3fdbc652d08c0113fcc373961fdfccfd8cc2b088992c465cc246d2a369db13e82cL
    // Encryption
    in_r <= 1024'h5b184aedd9aea2f16dc87001da926151a3530073d85500ab5b9ef9ef582f6eccfb4af4609695e105b9dc1a0845284c6f1aaa4582d8ce9f3682a4c920b040ded3ae4cd5b2edb910a24bd34282457ddc923de4a2db98432f68bee27a3d2328f6e257ab13e1d66bb6c4dd911a80f3291526766a2acc31be4960171a6f3c85cd7a7;
    in_r2 <= 1024'h610654ea1affa796d4ee25da281a5ac770223f748d061be89e519b814750ab9395df9c72b1e8ae65d87e5a1f004d38b3198b924b334d470258b2ed62d86e6604cc6592bc6327ce8d59838d3d206e951162324c23754e28734455a80676dfc526b18ad7cfa37c5c82a01a46423e0e4800013d01e02c54bec3e7b54a3e4af2cd17;
    in_m <= 1024'hfa4e7b51226515d0e92378ffe256d9eae5cacff8c27aaff54a4610610a7d0913304b50b9f696a1efa4623e5f7bad7b390e555ba7d273160c97d5b36df4fbf212c51b32a4d1246ef5db42cbd7dba82236dc21b5d2467bcd097411d85c2dcd7091da854ec1e2994493b226ee57f0cd6ead98995d533ce41b69fe8e590c37a32859;
    in_e <=  1024'hd6db;
    in_t <= 10'h10;
    in_x <=  1024'ha4260ac649fc1f3c7799f4d803919d69de4f85cb2bbb7d355c1fd7c0c8f784c5cea64825c5b553502364fad4664037598de4da1147015c5e408dd53d633651148eace4141fa295a9c03a30ce9e1f2eb390f402a3a5a1dc715ca3c278a5830b3fdbc652d08c0113fcc373961fdfccfd8cc2b088992c465cc246d2a369db13e82c;
    expected <=  1024'h1c1f19b8a6bef4e86bf8574df7b576cfc8d2f79010eae22f0e4a6c11fa34def6dcc19b0204f3cfb17f8735d364aa2aec61b3d0015d5a17f6eb6008daf85af4c184eea3de7e0d87e2447a540cada80aca352c7cfac809b7257aa646005f1f3611846dc881c9e0bee49ce09f59fba086a60a86e8e183bd1d82bdafaea75d183991;
    
    #`CLK_PERIOD
    start <= 1;
    #`CLK_PERIOD
    start <= 0;
    wait(done==1);
    result_ok <= (result == expected);
    expected <= in_x;
    in_x <= result;
	#`CLK_PERIOD
	
	// Decryption
	in_e <=  1024'h61b0e7ac004896c15f298d3f5ff02919c2968f1c6b1e3060b0ee4fc0f332c48a855d87d3640cdfe914587471e572be24506e127cf2c74f4a54f88a3a0c236c3caa151adccf9c3883aead59ee91725dff913c226ca142c3e2457ca7dc06fd3108e731564db719b1a0f55b46edd00fcbd63189cf4798ec1ed49d3d5f98e60afadd;
    in_t <= 10'd1023;
    #`CLK_PERIOD
    start <= 1;
    #`CLK_PERIOD
    start <= 0;
    wait(done==1);
    result_ok <= (result == expected);
	#`CLK_PERIOD
	$finish;
    end
endmodule