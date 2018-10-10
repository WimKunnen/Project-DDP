`timescale 1ns / 1ps

`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_adder();

    // Define internal regs and wires
    reg           clk;
    reg           resetn;
    reg  [1026:0] in_a;
    reg  [1026:0] in_b;
    reg           start;
    reg           subtract;
    wire [1027:0] result;
    wire          done;

    reg  [1027:0] expected;
    reg           result_ok;

    // Instantiating adder
    mpadder dut (
        .clk      (clk     ),
        .resetn   (resetn  ),
        .start    (start   ),
        .subtract (subtract),
        .in_a     (in_a    ),
        .in_b     (in_b    ),
        .result   (result  ),
        .done     (done    ));

    // Generate Clock
    initial begin
        clk = 0;
        forever #`CLK_HALF clk = ~clk;
    end

    // Initialize signals to zero
    initial begin
        in_a     <= 0;
        in_b     <= 0;
        subtract <= 0;
        start    <= 0;
    end

    // Reset the circuit
    initial begin
        resetn = 0;
        #`RESET_TIME
        resetn = 1;
    end

    task perform_add;
        input [1026:0] a;
        input [1026:0] b;
        begin
            in_a <= a;
            in_b <= b;
            start <= 1'd1;
            subtract <= 1'd0;
            #`CLK_PERIOD;
            start <= 1'd0;
            wait (done==1);
            #`CLK_PERIOD;
        end
    endtask

    task perform_sub;
        input [1026:0] a;
        input [1026:0] b;
        begin
            in_a <= a;
            in_b <= b;
            start <= 1'd1;
            subtract <= 1'd1;
            #`CLK_PERIOD;
            start <= 1'd0;
            wait (done==1);
            #`CLK_PERIOD;
        end
    endtask

    initial begin

    #`RESET_TIME

    /*************TEST ADDITION*************/
    
    $display("\nAddition with testvector 1");
    
    // Check if 1+1=2
    #`CLK_PERIOD;
    perform_add(1027'h1, 
                1027'h1);
    expected  = 1028'h2;
    wait (done==1);
    #`CLK_PERIOD;   
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    
    
    $display("\nAddition with testvector 2");

    // Test addition with large test vectors. 
    // You can generate your own vectors with testvector generator python script.
    perform_add(1027'h493b6761a0b1e90b4644c7b6e9504b3724a3ab05035414db29557f9bb789fcdfc7d9a1291f73b63756e42187bf1693b0c91b83b39c5d90a62d4a20174eda45eb6d72cb5aec8e7b15565c3efaabc289db0dbc12d780a144e446e8a350eb2f0149ea50d1f65ee45e41797ccf8343bc4da82e592a6322dcf940c3dcbbdf58f29103b,
                1027'h5a5468f37ce9d90445b8193ea750d077e150df3c824b3a9ee4326c518b0b2df79c109feef81bccd00f92397f461a5ed229d42a4e730ea84492389257ca1fce5d70bc999031182e53d2879aca7aa4279f4bb313454410c495f308b6f62f599d56e6a2029f3b02d8d5d45e04c6f1fe26ca84a44101917485096e7ba0debc24a027e);
    expected  = 1028'ha38fd0551d9bc20f8bfce0f590a11baf05f48a41859f4f7a0d87ebed42952ad763ea4118178f830766765b070530f282f2efae020f6c38eabf82b26f18fa1448de2f64eb1da6a96928e3d9c52666b17a596f261cc4b2097a39f15a471a889ea0d0f2d49599e737174ddad44a35ba7472b2fd6b64b4517e4a32585cbe1517312b9;
    wait (done==1);
    result_ok = (expected==result);
    #`CLK_PERIOD;     
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    
    /*************TEST SUBTRACTION*************/

    $display("\nSubtraction with testvector 1");
    
    // Check if 1-1=0
    #`CLK_PERIOD;
    perform_sub(1027'h1, 
                1027'h1);
    expected  = 1028'h0;
    wait (done==1);
    result_ok = (expected==result);
    #`CLK_PERIOD;    
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);


    $display("\nSubtraction with testvector 2");

    // Test subtraction with large test vectors. 
    // You can generate your own vectors with testvector generator python script.
    perform_sub(1027'h6fb734834375c10c35cd8b58baecd83e32a5249d46f5ff6def02094d2a8733ddd742f92c882b522402700bd74004776e7498e7545abccda330761b80d520326d8762484d6b60908f74f31fd320bb8b6cc5cef91632e1a4bac9b7b946602af8bb662889e6e8ed52c178506c1f3a064581c926c23b8ff85c247827b578aff2ef518,
                1027'h716dd59f485e8c4487b824d5e6500bd021216a91d1d85cb048560a974db668281526d378533bae9acd8c1bf1099f39cfec93111fa7dcf31d2e75410d88769068da07ecdf7bf562167e52817720d03a6d6bbcd76e997dfdb5e95e393446cdfe1601b2a424b06501d121037587cc0895c7bcc96a13e3312785ad637fa6fcb330218);
    expected  = 1028'hfe495ee3fb1734c7ae156682d49ccc6e1183ba0b751da2bda6abfeb5dcd0cbb5c21c25b434efa38934e3efe636653d9e8805d634b2dfda860200da734ca9a204ad5a5b6def6b2e78f6a09e5bffeb50ff5a1221a79963a704e0598012195cfaa56475e5c2388850f0574cf6976dfdafba0c5d5827acc7349ecac435d1b33fbf300;
    wait (done==1);
    result_ok = (expected==result);
    #`CLK_PERIOD;    
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    
    #`CLK_PERIOD;     

    $finish;

    end

endmodule