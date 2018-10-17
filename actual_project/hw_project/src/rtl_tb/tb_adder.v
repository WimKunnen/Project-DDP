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
	//$dumpvars(0, tb_adder);
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

    // Custom tests
    $display("\nAddition with custom test vectors.");
    
    // 0 + 0 
    $display("1)"); 
    #`CLK_PERIOD;
    perform_add(1027'h0, 
                1027'h0);
    expected  = 1028'h0;
    wait (done==1);
    #`CLK_PERIOD;   
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    #`CLK_PERIOD;

    // Test addition with minimal clock cycles between two additions.
    // Start becomes 1 to start the next addition immediately after the first addition communicates that is is done.
    $display("2)"); 
    #`CLK_PERIOD;
    perform_add(1027'h590314ef38956b949cf70b559598fff3810343f584b6e94df7e7ef563c2c2b20187b85e2ffdeb2899d5ccf50b80bb6e674edf9e03b16b07b96ebb90a7d020223ed01fec3facaa2e1e12bae6ddbbf40bc1bd8f921bc5b911a6de0148df4dce2f0b6ce2ba3d40996a0d1c66f26c6523a2d880db50fad6e04f97e6065d7607db4e21, 
                1027'h70e39380bd4d22631df98f504d60fcf527cfb8cf7d4f53bf7c204f9d3ea79ef965f0dac51c2b601e38f9b9aded472290a186a9e9f3c7041207d38cb68398186321e5fa1a21125f38153bebac11f7ebe508057da9adafa33465d25634ab0362185cc24fd61b29ccdbb489d8c537dfdaeb069b2604aabb5e23877002c84fa963d15);
    expected  = 1028'hc9e6a86ff5e28df7baf09aa5e2f9fce8a8d2fcc502063d0d74083ef37ad3ca197e6c60a81c0a12a7d65688fea552d9771674a3ca2eddb48d9ebf45c1009a1a870ee7f8de1bdd0219f6679a19edb72ca123de76cb6a0b344ed3b26ac29fe0450913907b79ef33637c865047ebfe3215188ea8db145829631d05d0689fb02718b36;
    wait (done==1);
    //#`CLK_PERIOD; No additional delay
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    //#`CLK_PERIOD; No additional delay    

    $display("3)"); 
    //#`CLK_PERIOD; No additional delay    
    perform_add(1027'h697eb5d979391c04af4817c51ba444fd4bb2381b7d2bd6230430594534dad3b9a877b364c51859c3b1515e2d668a837897f0e27fcf72328344267ffec09a11d10b36db9f8bfbee9c2185768fb08e45c2b95a7206ff6258be46f5a5666a794462d3954e77600b75cd8c4de2fefa732831f746a70c8203549d1e671c0363e4d15dd, 
                1027'h7107390a7b0819e9debffd9c8e178722e310a6175f83a3442fa07711947ef39c526db63d1841934adf1ddf91761a2dc0cd562358794308cbb5eb03fd309df63ae9d79090fe4e01700ccd47279f651f30271cd2633b6a797bb80b2d42a2a0361a183467c5cc833d5ffaa17f59176302706daf6c331353d75b71959af864e00db59);
    expected  = 1028'hda85eee3f44135ee8e081561a9bbcc202ec2de32dcaf796733d0d056c959c755fae569a1dd59ed0e906f3dbedca4b139654705d848b53b4efa1183fbf138080bf50e6c308a49f00c2e52bdb74ff364f2e077446a3accd239ff00d2a90d197a7cebc9b63d2c8eb32d86ef625811d62aa264f6133f95572bf88ffcb6fbc8c4df136;
    wait (done==1);
    #`CLK_PERIOD;   
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    #`CLK_PERIOD;

    $display("3)"); 
    #`CLK_PERIOD;
     perform_add(1027'h7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
1027'h7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    expected  = 1028'hffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe;
    wait (done==1);
    #`CLK_PERIOD;   
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    #`CLK_PERIOD;   

    $display("\nSubtraction with custom test vectors.");

    // 0 - 0
    $display("1)"); 
    #`CLK_PERIOD;
    perform_sub(0, 0);
    expected  = 1028'b0;
    wait (done==1);
    #`CLK_PERIOD;   
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    #`CLK_PERIOD;     

    $display("2)"); 
    #`CLK_PERIOD;
    perform_sub(1027'h5e12030e89153c485ada92e178c656d538e09204064149f9f49986f1e89345e60c4b8ad2cc2d21e3a98a212a1b8cebac099a7be9cdfa7db1bac5bcafe022650bc3824f73645ec526fcb61022ff7eeecf06b85fc1c619899dd86649553a419883a268fcc0b1fa44a6dcd7e8438d0e5408a3e75998a6e50420cd10b5196a21b2261, 
                1027'h7350eb6102f1fcaa52c84078db60172906df1264ca2fe7bc982163ebf24418daa286e8a74796f2fe621c411d6a02951dc607eef8d525edcd61f3198cdf08aaabfe31d5cbb798a263b68e5ddf0a6cf3413ec8c772cc3c4dd6fe468b2b1c2319d2aa389d1931b5a25973d3b2da31a61b8385969e11e6623c9ce2f71fc4eedc33829);
    expected  = 1028'heac117ad86233f9e081252689d663fac32017f9f3c11623d5c782305f64f2d0b69c4a22b84962ee5476de00cb18a568e43928cf0f8d48fe458d2a3230119ba5fc55079a7acc622c34627b243f511fb8dc7ef984ef9dd3bc6da1fbe2a1e1e7eb0f8305fa78044a24d690435695b6838851e50bb86c082c783ea1995547b457ea38;
    wait (done==1);
    #`CLK_PERIOD;   
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    #`CLK_PERIOD;    

    $display("3)"); 
    #`CLK_PERIOD;
    perform_sub(1027'h7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
1027'h7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    expected  = 1028'h0;
    wait (done==1);
    #`CLK_PERIOD;   
    result_ok = (expected==result);
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    #`CLK_PERIOD;     

    $finish;

    end

endmodule
