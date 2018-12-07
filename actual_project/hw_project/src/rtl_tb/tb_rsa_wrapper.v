`timescale 1ns / 1ps


`define NUM_OF_CORES 2


`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_rsa_wrapper();
    
    reg           clk;
    reg           resetn;
    reg  [  31:0] arm_to_fpga_cmd;
    reg           arm_to_fpga_cmd_valid;
    wire          arm_to_fpga_done;
    reg           arm_to_fpga_done_read;

    reg           arm_to_fpga_data_valid;
    wire          arm_to_fpga_data_ready;
    reg  [1023:0] arm_to_fpga_data;

    wire          fpga_to_arm_data_valid;
    reg           fpga_to_arm_data_ready;
    wire [1023:0] fpga_to_arm_data;

    wire [   3:0] leds;

    reg  [1023:0] input_data;
    reg  [1023:0] output_data;
    
    reg [31:0] compute_cmd;
    reg [1023:0] expected;
    reg result_ok;
        
    rsa_wrapper rsa_wrapper(
        .clk                    (clk                    ),
        .resetn                 (resetn                 ),

        .arm_to_fpga_cmd        (arm_to_fpga_cmd        ),
        .arm_to_fpga_cmd_valid  (arm_to_fpga_cmd_valid  ),
        .arm_to_fpga_done       (arm_to_fpga_done       ),
        .arm_to_fpga_done_read  (arm_to_fpga_done_read  ),

        .arm_to_fpga_data_valid (arm_to_fpga_data_valid ),
        .arm_to_fpga_data_ready (arm_to_fpga_data_ready ), 
        .arm_to_fpga_data       (arm_to_fpga_data       ),

        .fpga_to_arm_data_valid (fpga_to_arm_data_valid ),
        .fpga_to_arm_data_ready (fpga_to_arm_data_ready ),
        .fpga_to_arm_data       (fpga_to_arm_data       ),

        .leds                   (leds                   )
        );
        
    // Generate a clock
    initial begin
        clk = 0;
        forever #`CLK_HALF clk = ~clk;
    end
    
    // Reset
    initial begin
        resetn = 0;
        #`RESET_TIME resetn = 1;
    end
    
    // Initialise the values to zero
    initial begin
        arm_to_fpga_cmd         = 0;
        arm_to_fpga_cmd_valid   = 0;
        arm_to_fpga_done_read   = 0;
        arm_to_fpga_data_valid  = 0;
        arm_to_fpga_data        = 0;
        fpga_to_arm_data_ready  = 0;
        compute_cmd             = 0;
    end

    task send_cmd_to_hw;
    input [31:0] command;
    begin
        // Assert the command and valid
        arm_to_fpga_cmd <= command;
        arm_to_fpga_cmd_valid <= 1'b1;
        #`CLK_PERIOD;
        // Desassert the valid signal after one cycle
        arm_to_fpga_cmd_valid <= 1'b0;
        #`CLK_PERIOD;
    end
    endtask

    task send_data_to_hw;
    input [1023:0] data;
    begin
        // Assert data and valid
        arm_to_fpga_data <= data;
        arm_to_fpga_data_valid <= 1'b1;
        #`CLK_PERIOD;
        // Wait till accelerator is ready to read it
        wait(arm_to_fpga_data_ready == 1'b1);
        // It is read, do not continue asserting valid
        arm_to_fpga_data_valid <= 1'b0;   
        #`CLK_PERIOD;
    end
    endtask

    task read_data_from_hw;
    output [1023:0] odata;
    begin
        // Assert ready signal
        fpga_to_arm_data_ready <= 1'b1;
        #`CLK_PERIOD;
        // Wait for valid signal
        wait(fpga_to_arm_data_valid == 1'b1);
        // If valid read the output data
        odata = fpga_to_arm_data;
        // Co not continue asserting ready
        fpga_to_arm_data_ready <= 1'b0;
        #`CLK_PERIOD;
    end
    endtask

    task waitdone;
    begin
        // Wait for accelerator's done
        wait(arm_to_fpga_done == 1'b1);
        // Signal that is is read
        arm_to_fpga_done_read <= 1'b1;
        #`CLK_PERIOD;
        // Desassert the signal after one cycle
        arm_to_fpga_done_read <= 1'b0;
        #`CLK_PERIOD;
    end 
    endtask
    
    task compute_command;
    input [9:0] t;
    output [31:0] command;
    begin
        command = {t, 22'b0}; 
    end
    endtask

    localparam CMD_COMPUTE          = 32'd0;
    localparam CMD_READ_X           = 32'd1;
    localparam CMD_READ_E           = 32'd3;
    localparam CMD_READ_R           = 32'd5;
    localparam CMD_READ_R2          = 32'd7;
    localparam CMD_READ_M           = 32'd9;   
    localparam CMD_WRITE_RESULT     = 32'd2;
    localparam CMD_WRITE_X          = 32'd4;
    localparam CMD_WRITE_E          = 32'd6;
    localparam CMD_WRITE_M          = 32'd8;
    localparam CMD_WRITE_R          = 32'd10;
    localparam CMD_WRITE_R2         = 32'd12;
    

    initial begin

        #`RESET_TIME
        result_ok <= 0;

        // RSA
        // Seed 2018.1 test        
          
//        --- Precomputed Values
//        p            =  0xfd80487fb832db6ec4253c85e79446d81458ed4c19961031bc190db8060d4dca1ff8a52d795ebcd0770e0cf9ba4e0dc8e751a7a152557a0b5968c2ccee895953L
//        q            =  0xfcc62312fbd14327a70d448b8bcdb0183b94a6c368424b39a9316f922150325c2c950fba496dda7767555b95e82d0d9516eef83ccd36e8054c80abf745ac0623L
//        Modulus      =  0xfa4e7b51226515d0e92378ffe256d9eae5cacff8c27aaff54a4610610a7d0913304b50b9f696a1efa4623e5f7bad7b390e555ba7d273160c97d5b36df4fbf212c51b32a4d1246ef5db42cbd7dba82236dc21b5d2467bcd097411d85c2dcd7091da854ec1e2994493b226ee57f0cd6ead98995d533ce41b69fe8e590c37a32859L
//        Enc exp      =  0xdb6b
//        Dec exp      =  0x5dafa8338cfd5e5c95bc1b8cf179c8c635e9f805dbb16d5782c6cc76d935467388465fb01df29f5123e1a1429b221e44ffdd2744bbcd5abae08e1cf99dac542a9e1b62182e288f95297971a79f243b05123ea753c7170d144bfd981365f0dd50a891a66781f93b8683063c6b1c78b4a1cc4a07fd7e58ca7d41b489001af386c3L
//        Message      =  0xa4260ac649fc1f3c7799f4d803919d69de4f85cb2bbb7d355c1fd7c0c8f784c5cea64825c5b553502364fad4664037598de4da1147015c5e408dd53d633651148eace4141fa295a9c03a30ce9e1f2eb390f402a3a5a1dc715ca3c278a5830b3fdbc652d08c0113fcc373961fdfccfd8cc2b088992c465cc246d2a369db13e82cL
//        R            =  0x5b184aedd9aea2f16dc87001da926151a3530073d85500ab5b9ef9ef582f6eccfb4af4609695e105b9dc1a0845284c6f1aaa4582d8ce9f3682a4c920b040ded3ae4cd5b2edb910a24bd34282457ddc923de4a2db98432f68bee27a3d2328f6e257ab13e1d66bb6c4dd911a80f3291526766a2acc31be4960171a6f3c85cd7a7L
//        R2           =  610654ea1affa796d4ee25da281a5ac770223f748d061be89e519b814750ab9395df9c72b1e8ae65d87e5a1f004d38b3198b924b334d470258b2ed62d86e6604cc6592bc6327ce8d59838d3d206e951162324c23754e28734455a80676dfc526b18ad7cfa37c5c82a01a46423e0e4800013d01e02c54bec3e7b54a3e4af2cd17L

//        --- Execute RSA (for verification)
//        Ciphertext   =  0x1c1f19b8a6bef4e86bf8574df7b576cfc8d2f79010eae22f0e4a6c11fa34def6dcc19b0204f3cfb17f8735d364aa2aec61b3d0015d5a17f6eb6008daf85af4c184eea3de7e0d87e2447a540cada80aca352c7cfac809b7257aa646005f1f3611846dc881c9e0bee49ce09f59fba086a60a86e8e183bd1d82bdafaea75d183991L
//        Plaintext    =  0xa4260ac649fc1f3c7799f4d803919d69de4f85cb2bbb7d355c1fd7c0c8f784c5cea64825c5b553502364fad4664037598de4da1147015c5e408dd53d633651148eace4141fa295a9c03a30ce9e1f2eb390f402a3a5a1dc715ca3c278a5830b3fdbc652d08c0113fcc373961fdfccfd8cc2b088992c465cc246d2a369db13e82cL
        
//        --- Execute RSA in HW (slow)
//        Ciphertext   =  0x1c1f19b8a6bef4e86bf8574df7b576cfc8d2f79010eae22f0e4a6c11fa34def6dcc19b0204f3cfb17f8735d364aa2aec61b3d0015d5a17f6eb6008daf85af4c184eea3de7e0d87e2447a540cada80aca352c7cfac809b7257aa646005f1f3611846dc881c9e0bee49ce09f59fba086a60a86e8e183bd1d82bdafaea75d183991L
//        Plaintext    =  0xa4260ac649fc1f3c7799f4d803919d69de4f85cb2bbb7d355c1fd7c0c8f784c5cea64825c5b553502364fad4664037598de4da1147015c5e408dd53d633651148eace4141fa295a9c03a30ce9e1f2eb390f402a3a5a1dc715ca3c278a5830b3fdbc652d08c0113fcc373961fdfccfd8cc2b088992c465cc246d2a369db13e82cL

        $display("Test for seed 2018.1");
                
        // Message = 0xa4260ac649fc1f3c7799f4d803919d69de4f85cb2bbb7d355c1fd7c0c8f784c5cea64825c5b553502364fad4664037598de4da1147015c5e408dd53d633651148eace4141fa295a9c03a30ce9e1f2eb390f402a3a5a1dc715ca3c278a5830b3fdbc652d08c0113fcc373961fdfccfd8cc2b088992c465cc246d2a369db13e82cL
        input_data <= 1024'ha4260ac649fc1f3c7799f4d803919d69de4f85cb2bbb7d355c1fd7c0c8f784c5cea64825c5b553502364fad4664037598de4da1147015c5e408dd53d633651148eace4141fa295a9c03a30ce9e1f2eb390f402a3a5a1dc715ca3c278a5830b3fdbc652d08c0113fcc373961fdfccfd8cc2b088992c465cc246d2a369db13e82c;
        send_cmd_to_hw(CMD_READ_X);
        send_data_to_hw(input_data);
        waitdone();
        
        // Enc exp = 0xdb6b
        // Note: we mirrored the bits first
        input_data <= 1024'hd6db;
        send_cmd_to_hw(CMD_READ_E);
        send_data_to_hw(input_data);
        waitdone();
        
        // Modulus = 0xfa4e7b51226515d0e92378ffe256d9eae5cacff8c27aaff54a4610610a7d0913304b50b9f696a1efa4623e5f7bad7b390e555ba7d273160c97d5b36df4fbf212c51b32a4d1246ef5db42cbd7dba82236dc21b5d2467bcd097411d85c2dcd7091da854ec1e2994493b226ee57f0cd6ead98995d533ce41b69fe8e590c37a32859L
        input_data <= 1024'hfa4e7b51226515d0e92378ffe256d9eae5cacff8c27aaff54a4610610a7d0913304b50b9f696a1efa4623e5f7bad7b390e555ba7d273160c97d5b36df4fbf212c51b32a4d1246ef5db42cbd7dba82236dc21b5d2467bcd097411d85c2dcd7091da854ec1e2994493b226ee57f0cd6ead98995d533ce41b69fe8e590c37a32859;
        send_cmd_to_hw(CMD_READ_M);
        send_data_to_hw(input_data);
        waitdone();
        
        // R
        input_data <= 1024'h5b184aedd9aea2f16dc87001da926151a3530073d85500ab5b9ef9ef582f6eccfb4af4609695e105b9dc1a0845284c6f1aaa4582d8ce9f3682a4c920b040ded3ae4cd5b2edb910a24bd34282457ddc923de4a2db98432f68bee27a3d2328f6e257ab13e1d66bb6c4dd911a80f3291526766a2acc31be4960171a6f3c85cd7a7;
        send_cmd_to_hw(CMD_READ_R);
        send_data_to_hw(input_data);
        waitdone();
        
        // R2        
        input_data <= 1024'h610654ea1affa796d4ee25da281a5ac770223f748d061be89e519b814750ab9395df9c72b1e8ae65d87e5a1f004d38b3198b924b334d470258b2ed62d86e6604cc6592bc6327ce8d59838d3d206e951162324c23754e28734455a80676dfc526b18ad7cfa37c5c82a01a46423e0e4800013d01e02c54bec3e7b54a3e4af2cd17;
        send_cmd_to_hw(CMD_READ_R2);
        send_data_to_hw(input_data);
        waitdone();

        // Compute encryption
        expected <= 1024'h1c1f19b8a6bef4e86bf8574df7b576cfc8d2f79010eae22f0e4a6c11fa34def6dcc19b0204f3cfb17f8735d364aa2aec61b3d0015d5a17f6eb6008daf85af4c184eea3de7e0d87e2447a540cada80aca352c7cfac809b7257aa646005f1f3611846dc881c9e0bee49ce09f59fba086a60a86e8e183bd1d82bdafaea75d183991;

        compute_command(10'd16, compute_cmd);
        send_cmd_to_hw(compute_cmd);
        waitdone();

	    // Read result
        send_cmd_to_hw(CMD_WRITE_RESULT);
        read_data_from_hw(output_data);
        waitdone();
        
        result_ok <= (expected == output_data);
        if (expected == output_data)
            $display("Encryption is correct.");
        $display("Encoded ciphertext is      %h", output_data);
            
        // Decryption
        // Ciphertext = 0x1c1f19b8a6bef4e86bf8574df7b576cfc8d2f79010eae22f0e4a6c11fa34def6dcc19b0204f3cfb17f8735d364aa2aec61b3d0015d5a17f6eb6008daf85af4c184eea3de7e0d87e2447a540cada80aca352c7cfac809b7257aa646005f1f3611846dc881c9e0bee49ce09f59fba086a60a86e8e183bd1d82bdafaea75d183991
        input_data <= expected;
        send_cmd_to_hw(CMD_READ_X);
        send_data_to_hw(input_data);
        waitdone();
                
        // Dec exp = 0x5dafa8338cfd5e5c95bc1b8cf179c8c635e9f805dbb16d5782c6cc76d935467388465fb01df29f5123e1a1429b221e44ffdd2744bbcd5abae08e1cf99dac542a9e1b62182e288f95297971a79f243b05123ea753c7170d144bfd981365f0dd50a891a66781f93b8683063c6b1c78b4a1cc4a07fd7e58ca7d41b489001af386c3L
        // Note: we mirrored the bits first
        input_data <= 1024'h61b0e7ac004896c15f298d3f5ff02919c2968f1c6b1e3060b0ee4fc0f332c48a855d87d3640cdfe914587471e572be24506e127cf2c74f4a54f88a3a0c236c3caa151adccf9c3883aead59ee91725dff913c226ca142c3e2457ca7dc06fd3108e731564db719b1a0f55b46edd00fcbd63189cf4798ec1ed49d3d5f98e60afadd;
        send_cmd_to_hw(CMD_READ_E);
        send_data_to_hw(input_data);
        waitdone();
        
        // Compute decryption
        expected <= 1024'ha4260ac649fc1f3c7799f4d803919d69de4f85cb2bbb7d355c1fd7c0c8f784c5cea64825c5b553502364fad4664037598de4da1147015c5e408dd53d633651148eace4141fa295a9c03a30ce9e1f2eb390f402a3a5a1dc715ca3c278a5830b3fdbc652d08c0113fcc373961fdfccfd8cc2b088992c465cc246d2a369db13e82c;
        
        compute_command(10'd1023, compute_cmd);
        send_cmd_to_hw(compute_cmd);
        waitdone();
        
        // Read result
        send_cmd_to_hw(CMD_WRITE_RESULT);
        read_data_from_hw(output_data);
        waitdone();
                
        result_ok <= (expected == output_data);
        if (expected == output_data)
            $display("Decryption is correct.");

        //// Print the result.
        $display("Output is      %h", output_data);
        #`CLK_PERIOD;
        
        // Seed 2018.2 test
        
//        --- Precomputed Values
//        p            =  0xdbd1acc6c12bc01f67daac66bde7c33ce9f69897f04321e548f477ffd5728b0f4eff31109ca8ceac26cd396e0c9e7c66f05339e693b4176ff5ce048c68ad1175L
//        q            =  0xefbdb975d2e394090cb7b88b28f9a329b9974819be1ec678190f42cba04ca75f5874d07e6bbd914f78b947bb89774b5d04c4e14514cd5d423765520b34098615L
//        Modulus      =  0xcddba959ced977dd4bdb114deaabeb1f1744eb7032a9d00319526e38f3e614bee7b863b79b780f4b3655ec68498a39fdb84ee44ac0fbee47a3e7872712042b2cef9c27dc2841800d2ff367029c20e38d0fce9e40d9bec93dcc7a8f07a1e3158e49c9b720a390f567abe067401e377ed9d36b62d670c0abc5a3aaedf78e72ac99L
//        Enc exp      =  0xcfb5
//        Dec exp      =  0x1474f66bf0639ae7f3426ef5c2c4b651ce671712e56123122f2093a54ff6f4249788eb1c701fc921f7da02ef548484ce9f59bf97a7df608e31abddd33a3d73bfebea19b3bce178279e7ed57efc63b5bcd2f17c58ada4cf340f2eb079109261fe6094e8449a7621ec6f53239957608b4e8917810773fb52fdaed3053ec71113ddL
//        Message      =  0x8d8297ae2472f6ba6ec330887f342670188261d4f69ba521c0562aeab14868d7b9c2bf4cd44abc1dd7de351796fb772a5f1bce9883ec849eb21dfd42736d1fbef646811a048db19845ed2caddbfffe2c299121619e4bb03d4edf0a110602e1e210346fe8052b1e5fef76b462ddba66640594133d9c8ebed08c45480a8fc29643L
//        R            =  0x322456a631268822b424eeb2155414e0e8bb148fcd562ffce6ad91c70c19eb4118479c486487f0b4c9aa1397b675c60247b11bb53f0411b85c1878d8edfbd4d31063d823d7be7ff2d00c98fd63df1c72f03161bf264136c2338570f85e1cea71b63648df5c6f0a98541f98bfe1c881262c949d298f3f543a5c551208718d5367
//        R2           =  0xad0bb962ba9aa3630678bddd3c7342adaab4cc31ba36f41c1e6ae11c2321379ec43a771f507779d57e963d6a19026b311d386cfe86709dfa8cdd30435f74eddee2c3728d23536af374053eb5ac9df4fa7b09294c13ff24b68e3e86ef55714cdd312db89abc46cefcb8db30117d2f9f198dbcf2ec139e1dfa1acc7901bdcd9707
//        --- Execute RSA (for verification)
//        Ciphertext   =  0x11af76f641052ec5f92e70676c110ca012662b604c0c0f02acb409c50a5f3591ddc7f12ddf29455a03fa18b689d5a8005a718f249be86ac9169fc2b706efde849c209cf574a5ebedbcdc7e90499640ecac1c11d5b9db8bc01a6046f242fe08ae585926d876fb5ad559b01d6fac9c98cda579bece5c84339896964616a2583c82L
//        Plaintext    =  0x8d8297ae2472f6ba6ec330887f342670188261d4f69ba521c0562aeab14868d7b9c2bf4cd44abc1dd7de351796fb772a5f1bce9883ec849eb21dfd42736d1fbef646811a048db19845ed2caddbfffe2c299121619e4bb03d4edf0a110602e1e210346fe8052b1e5fef76b462ddba66640594133d9c8ebed08c45480a8fc29643L
        
//        --- Execute RSA in HW (slow)
//        Ciphertext   =  0x11af76f641052ec5f92e70676c110ca012662b604c0c0f02acb409c50a5f3591ddc7f12ddf29455a03fa18b689d5a8005a718f249be86ac9169fc2b706efde849c209cf574a5ebedbcdc7e90499640ecac1c11d5b9db8bc01a6046f242fe08ae585926d876fb5ad559b01d6fac9c98cda579bece5c84339896964616a2583c82L
//        Plaintext    =  0x8d8297ae2472f6ba6ec330887f342670188261d4f69ba521c0562aeab14868d7b9c2bf4cd44abc1dd7de351796fb772a5f1bce9883ec849eb21dfd42736d1fbef646811a048db19845ed2caddbfffe2c299121619e4bb03d4edf0a110602e1e210346fe8052b1e5fef76b462ddba66640594133d9c8ebed08c45480a8fc29643L


        $display("Test for seed 2018.2");
                
        // Message = 0x8d8297ae2472f6ba6ec330887f342670188261d4f69ba521c0562aeab14868d7b9c2bf4cd44abc1dd7de351796fb772a5f1bce9883ec849eb21dfd42736d1fbef646811a048db19845ed2caddbfffe2c299121619e4bb03d4edf0a110602e1e210346fe8052b1e5fef76b462ddba66640594133d9c8ebed08c45480a8fc29643
        input_data <= 1024'h8d8297ae2472f6ba6ec330887f342670188261d4f69ba521c0562aeab14868d7b9c2bf4cd44abc1dd7de351796fb772a5f1bce9883ec849eb21dfd42736d1fbef646811a048db19845ed2caddbfffe2c299121619e4bb03d4edf0a110602e1e210346fe8052b1e5fef76b462ddba66640594133d9c8ebed08c45480a8fc29643;
        send_cmd_to_hw(CMD_READ_X);
        send_data_to_hw(input_data);
        waitdone();
        
        // Enc exp = 0xcfb5
        // Note: we mirrored the bits first
        input_data <= 1024'hadf3;
        send_cmd_to_hw(CMD_READ_E);
        send_data_to_hw(input_data);
        waitdone();
        
        // Modulus = 0xcddba959ced977dd4bdb114deaabeb1f1744eb7032a9d00319526e38f3e614bee7b863b79b780f4b3655ec68498a39fdb84ee44ac0fbee47a3e7872712042b2cef9c27dc2841800d2ff367029c20e38d0fce9e40d9bec93dcc7a8f07a1e3158e49c9b720a390f567abe067401e377ed9d36b62d670c0abc5a3aaedf78e72ac99L
        input_data <= 1024'hcddba959ced977dd4bdb114deaabeb1f1744eb7032a9d00319526e38f3e614bee7b863b79b780f4b3655ec68498a39fdb84ee44ac0fbee47a3e7872712042b2cef9c27dc2841800d2ff367029c20e38d0fce9e40d9bec93dcc7a8f07a1e3158e49c9b720a390f567abe067401e377ed9d36b62d670c0abc5a3aaedf78e72ac99;
        send_cmd_to_hw(CMD_READ_M);
        send_data_to_hw(input_data);
        waitdone();
        
        // R = 0x322456a631268822b424eeb2155414e0e8bb148fcd562ffce6ad91c70c19eb4118479c486487f0b4c9aa1397b675c60247b11bb53f0411b85c1878d8edfbd4d31063d823d7be7ff2d00c98fd63df1c72f03161bf264136c2338570f85e1cea71b63648df5c6f0a98541f98bfe1c881262c949d298f3f543a5c551208718d5367
        input_data <= 1024'h322456a631268822b424eeb2155414e0e8bb148fcd562ffce6ad91c70c19eb4118479c486487f0b4c9aa1397b675c60247b11bb53f0411b85c1878d8edfbd4d31063d823d7be7ff2d00c98fd63df1c72f03161bf264136c2338570f85e1cea71b63648df5c6f0a98541f98bfe1c881262c949d298f3f543a5c551208718d5367;
        send_cmd_to_hw(CMD_READ_R);
        send_data_to_hw(input_data);
        waitdone();
        
        // R2 = 0xad0bb962ba9aa3630678bddd3c7342adaab4cc31ba36f41c1e6ae11c2321379ec43a771f507779d57e963d6a19026b311d386cfe86709dfa8cdd30435f74eddee2c3728d23536af374053eb5ac9df4fa7b09294c13ff24b68e3e86ef55714cdd312db89abc46cefcb8db30117d2f9f198dbcf2ec139e1dfa1acc7901bdcd9707      
        input_data <= 1024'had0bb962ba9aa3630678bddd3c7342adaab4cc31ba36f41c1e6ae11c2321379ec43a771f507779d57e963d6a19026b311d386cfe86709dfa8cdd30435f74eddee2c3728d23536af374053eb5ac9df4fa7b09294c13ff24b68e3e86ef55714cdd312db89abc46cefcb8db30117d2f9f198dbcf2ec139e1dfa1acc7901bdcd9707;
        send_cmd_to_hw(CMD_READ_R2);
        send_data_to_hw(input_data);
        waitdone();

        // Encryption
        expected <= 1024'h11af76f641052ec5f92e70676c110ca012662b604c0c0f02acb409c50a5f3591ddc7f12ddf29455a03fa18b689d5a8005a718f249be86ac9169fc2b706efde849c209cf574a5ebedbcdc7e90499640ecac1c11d5b9db8bc01a6046f242fe08ae585926d876fb5ad559b01d6fac9c98cda579bece5c84339896964616a2583c82;

        compute_command(10'd16, compute_cmd);
        send_cmd_to_hw(compute_cmd);
        waitdone();

	    // Read result
        send_cmd_to_hw(CMD_WRITE_RESULT);
        read_data_from_hw(output_data);
        waitdone();
        
        result_ok <= (expected == output_data);
        if (expected == output_data)
            $display("Encryption is correct.");
        $display("Encoded ciphertext is      %h", output_data);

            
        // Decryption
        // Ciphertext = 0x11af76f641052ec5f92e70676c110ca012662b604c0c0f02acb409c50a5f3591ddc7f12ddf29455a03fa18b689d5a8005a718f249be86ac9169fc2b706efde849c209cf574a5ebedbcdc7e90499640ecac1c11d5b9db8bc01a6046f242fe08ae585926d876fb5ad559b01d6fac9c98cda579bece5c84339896964616a2583c82L
        input_data <= expected;
        send_cmd_to_hw(CMD_READ_X);
        send_data_to_hw(input_data);
        waitdone();
                        
        // Dec exp = 0x1474f66bf0639ae7f3426ef5c2c4b651ce671712e56123122f2093a54ff6f4249788eb1c701fc921f7da02ef548484ce9f59bf97a7df608e31abddd33a3d73bfebea19b3bce178279e7ed57efc63b5bcd2f17c58ada4cf340f2eb079109261fe6094e8449a7621ec6f53239957608b4e8917810773fb52fdaed3053ec71113ddL
        // Note: we mirrored the bits first
        input_data <= 1024'h1779111c6f94196eb7e95bf9dc103d122e5a20dd5338995ec6f08dcb2442e520cff0c92113c1ae9e059e64b6a347d1e967b5b8c7efd56fcf3c83d0e7b9b30afaffb9d78b99777ab18e20df7cbd3fb35f2e6424255ee80b7df0927f01c71ae23d2485edfe54b9209e891890d4e91d1cce714da46875eec859fceb38c1facde5c5;
        send_cmd_to_hw(CMD_READ_E);
        send_data_to_hw(input_data);
        waitdone();
                
        // Compute decryption
        expected <= 1024'h8d8297ae2472f6ba6ec330887f342670188261d4f69ba521c0562aeab14868d7b9c2bf4cd44abc1dd7de351796fb772a5f1bce9883ec849eb21dfd42736d1fbef646811a048db19845ed2caddbfffe2c299121619e4bb03d4edf0a110602e1e210346fe8052b1e5fef76b462ddba66640594133d9c8ebed08c45480a8fc29643;
          
        compute_command(10'd1021, compute_cmd);
        send_cmd_to_hw(compute_cmd);
        waitdone();
                
        // Read result
        send_cmd_to_hw(CMD_WRITE_RESULT);
        read_data_from_hw(output_data);
        waitdone();
                      
        result_ok <= (expected == output_data);
        if (expected == output_data)
            $display("Decryption is correct.");

        //// Print the result.
        $display("Decoded plaintext is      %h", output_data);

        #`CLK_PERIOD;
        
        // Seed 2018.3 test
        
//        --- Precomputed Values
//        p            =  0xf5110969b02e9cb93740527826f5a5407965f9ac586667dccb3bf87968e6357acb0e86c87a0953dd560e4585b696b0124786c2e304199c71d016a657662b0b21L
//        q            =  0xe5bd832fcec366b7b1b83a248284756f5b40d67a657cc92798ab336c752a6b5606df87febdbbbf6074eb097744292987ea15be285b9f6076c0d230394e0b40d3L
//        Modulus      =  0xdbeda894f981580c70419151021f61921bf68ecb08a74b1cf52114f0d6576baef90575a87d9ef4cf5e03c3d53adf2fde6ab69401864218d4f0047f0fbc10251233e618629d9ca0c860ba44d54687c8e623876dede34365266bff2958cfeb938c242b15339e126d8e6d7302a2eb172d0e5f5fa80aa39342f7a5e11f2a80ad6c33L
//        Enc exp      =  0xc203
//        Dec exp      =  0x42b68f1744c5e54f51f0cf1752111894fc0e2523d7ab35681cffdd94d99b6c3b7a5ade025457177eea17f9ca172826d6b23a42690b325f6f33ffbc32e2310759f826a7f10083a577e734fec985d8c5621a5966e4a57111b20247a79a44727c2c73a1a6f6dbd5dc246af3b2c7e4d6c99282174d85745d84d12e5fc1a81d75202bL
//        Message      =  0x89ea1b7bef7a1f8c9a21c464b2c4173138be781b531aa96bb9b10268b2fef6f7b25c7261ac5eb4d8491d362697a1f4ed6df383a7e8f8ef5ce250f2801cbb5370f1f517d66ea4c9228387a0051812fe70010b2623b18f8c685005ca80150e0f0cba361ed01c6878f2df13bf9ef8eeeea31234f08735460b11eaebb19b899429f1L
        
//        --- Execute RSA (for verification)
//        Ciphertext   =  0xc4655a31c2085259d07601d5753a7f3ec996c0a6d4b4f264c9b5c676e842db267c9d0feb68fb3c45fc5993f91d1bad0844ba82f6f77ac56d45f52380dba2d295be69a77c2daecc7ac0aceb5dda22c6a0b9e57eb627c20c71f2783b7262a063ed2c806d34502a5c86aaa79316e8b69a7d92bd10090d3548f5641ae71e237d4ff3L
//        Plaintext    =  0x89ea1b7bef7a1f8c9a21c464b2c4173138be781b531aa96bb9b10268b2fef6f7b25c7261ac5eb4d8491d362697a1f4ed6df383a7e8f8ef5ce250f2801cbb5370f1f517d66ea4c9228387a0051812fe70010b2623b18f8c685005ca80150e0f0cba361ed01c6878f2df13bf9ef8eeeea31234f08735460b11eaebb19b899429f1L
        
//        --- Execute RSA in HW (slow)
//        Ciphertext   =  0xc4655a31c2085259d07601d5753a7f3ec996c0a6d4b4f264c9b5c676e842db267c9d0feb68fb3c45fc5993f91d1bad0844ba82f6f77ac56d45f52380dba2d295be69a77c2daecc7ac0aceb5dda22c6a0b9e57eb627c20c71f2783b7262a063ed2c806d34502a5c86aaa79316e8b69a7d92bd10090d3548f5641ae71e237d4ff3L
//        Plaintext    =  0x89ea1b7bef7a1f8c9a21c464b2c4173138be781b531aa96bb9b10268b2fef6f7b25c7261ac5eb4d8491d362697a1f4ed6df383a7e8f8ef5ce250f2801cbb5370f1f517d66ea4c9228387a0051812fe70010b2623b18f8c685005ca80150e0f0cba361ed01c6878f2df13bf9ef8eeeea31234f08735460b11eaebb19b899429f1L

        $display("Test for seed 2018.3");
                        
                input_data <= 1024'h89ea1b7bef7a1f8c9a21c464b2c4173138be781b531aa96bb9b10268b2fef6f7b25c7261ac5eb4d8491d362697a1f4ed6df383a7e8f8ef5ce250f2801cbb5370f1f517d66ea4c9228387a0051812fe70010b2623b18f8c685005ca80150e0f0cba361ed01c6878f2df13bf9ef8eeeea31234f08735460b11eaebb19b899429f1;
                send_cmd_to_hw(CMD_READ_X);
                send_data_to_hw(input_data);
                waitdone();
                
                input_data <= 1024'hc043;
                send_cmd_to_hw(CMD_READ_E);
                send_data_to_hw(input_data);
                waitdone();
                
                input_data <= 1024'hdbeda894f981580c70419151021f61921bf68ecb08a74b1cf52114f0d6576baef90575a87d9ef4cf5e03c3d53adf2fde6ab69401864218d4f0047f0fbc10251233e618629d9ca0c860ba44d54687c8e623876dede34365266bff2958cfeb938c242b15339e126d8e6d7302a2eb172d0e5f5fa80aa39342f7a5e11f2a80ad6c33;
                send_cmd_to_hw(CMD_READ_M);
                send_data_to_hw(input_data);
                waitdone();
                
                input_data <= 1024'h2412576b067ea7f38fbe6eaefde09e6de4097134f758b4e30adeeb0f29a8945106fa8a5782610b30a1fc3c2ac520d02195496bfe79bde72b0ffb80f043efdaedcc19e79d62635f379f45bb2ab9783719dc7892121cbc9ad99400d6a730146c73dbd4eacc61ed9271928cfd5d14e8d2f1a0a057f55c6cbd085a1ee0d57f5293cd;
                send_cmd_to_hw(CMD_READ_R);
                send_data_to_hw(input_data);
                waitdone();
                
                input_data <= 1024'hafac41599c2e37f0ef360d4e3c4f399a2947a2f268038a0e88bce05696467465a74017d814a4116246d90d31f1518e8bca2018d4162ac91654712e66d308a663fe2e0465fd73fe5e17cc988d6da43f974ae6e34030995e63a40536a7b53e55e7be9f00e19bd10a4420d7a983a11c12d773cab9f321808c4060a0c1c0ed571129;
                send_cmd_to_hw(CMD_READ_R2);
                send_data_to_hw(input_data);
                waitdone();
        
                expected <= 1024'hc4655a31c2085259d07601d5753a7f3ec996c0a6d4b4f264c9b5c676e842db267c9d0feb68fb3c45fc5993f91d1bad0844ba82f6f77ac56d45f52380dba2d295be69a77c2daecc7ac0aceb5dda22c6a0b9e57eb627c20c71f2783b7262a063ed2c806d34502a5c86aaa79316e8b69a7d92bd10090d3548f5641ae71e237d4ff3;
        
                compute_command(10'd16, compute_cmd);
                send_cmd_to_hw(compute_cmd);
                waitdone();
        
                send_cmd_to_hw(CMD_WRITE_RESULT);
                read_data_from_hw(output_data);
                waitdone();
                
                result_ok <= (expected == output_data);
                if (expected == output_data)
                    $display("Encryption is correct.");
                $display("Encoded ciphertext is      %h", output_data);
                    
                // Decryption
                input_data <= expected;
                send_cmd_to_hw(CMD_READ_X);
                send_data_to_hw(input_data);
                waitdone();
                                
                input_data <= 1024'h6a02575c0ac1fd3a4590dd1750d97420a4c9b593f1a6e7ab121dd5edb7b2c2e71a1f27112cf2f12026c4475293b34d2c23518dd0c9bf9673f752e08047f2b20fcd704623a61effe67b7d26684b212e26b5b20a7429cff42bbf747515203dad2f6e1b6ccd94ddff9c0b566af5e252381f948c4425747987c57953d1917478b6a1;
                send_cmd_to_hw(CMD_READ_E);
                send_data_to_hw(input_data);
                waitdone();
                        
                expected <= 1024'h89ea1b7bef7a1f8c9a21c464b2c4173138be781b531aa96bb9b10268b2fef6f7b25c7261ac5eb4d8491d362697a1f4ed6df383a7e8f8ef5ce250f2801cbb5370f1f517d66ea4c9228387a0051812fe70010b2623b18f8c685005ca80150e0f0cba361ed01c6878f2df13bf9ef8eeeea31234f08735460b11eaebb19b899429f1;
                  
                compute_command(10'd1023, compute_cmd);
                send_cmd_to_hw(compute_cmd);
                waitdone();
                        
                send_cmd_to_hw(CMD_WRITE_RESULT);
                read_data_from_hw(output_data);
                waitdone();
                              
                result_ok <= (expected == output_data);
                if (expected == output_data)
                    $display("Decryption is correct.");
        
                $display("Decoded plaintext is      %h", output_data);

                #`CLK_PERIOD;

// Sorry for the poor indentation but Vivado handles indentation very poorly and I am tired of manually fixing it.
        
//    --- Precomputed Values
//p            =  0x9df4b8dbaf3f7922243b4d5541f41f532790f645cc9a772b9d7b36b6a0e5015eaa70f4aec9f487aca618f7adcc58cdd35cc63358e90d3614cbefc54b211f8cbbL
//q            =  0xdd5a32423ee7ca2e2a4be8164b93a345a3ae1de7ceb28cd5c59606c4270647bb1ded86d2d52f0382beb9820a3449868445d0bb0f7d6226919d14f8503f260359L
//Modulus      =  0x8893eaa14f8842183be9e214982cce482f5a0d0337799ea628ad9a7fdb1a87c764c81c6087363b2f94a2095825e93a2b0a248074f6e3ef1dd55572d525cebe7dd3f2e70c77db25787bdb48dafddc05282a38b3f51add7adfc72566e25d3a7853c5b7054ef5e4cc2409f8351c5c7c3c22bae297ec72162a0513c64942cb601e03L
//Enc exp      =  0xd1e3
//Dec exp      =  0x2ce8f28468c8f23bbd4fc026d3cae7f769f50bcadb683b15e402c033fd7dea647845a69a01b4532c1823061dfc55618455d155384db6f996012b45b7079fe9ad0f29d0b4435e314b8424fc072e1e19316a96f78c91953d32df5822b15dcf9b68ce18965251931eb62aa19ef8ab44f5df5904b3b17cb8676f78d8690ee1bb010bL
//Message      =  0x805a046dd9eef68f63235d226b1571a3371026f2ecdf1f6c96a63d1d0f7bc0787398fcffeb32eb1c1934636b81e74b325f32031ef50f7b3402f7c88392606c0a441aac9f6d974046312738ba882648c68fd3bd15cd851c50b91d7dfc62223df44caf5d6b802846fc7ef43a90e50a4507437facdee196fdaca0b8caeb3b990a79L

//--- Execute RSA (for verification)
//Ciphertext   =  0x120dfce55cb49d828dccca637e756c361f603a280929239ddd91c188bc91a10d8bb7adcea555748123d4d4fa4c9ae5a1e4fcd834ccd504e8eec9433ffff6e1ceaa2c9e5f4d584f668e6346d458aa7677e8322c03c2358f46f339d38e75ea6d7e911f7122e1865acad95e9ff1f4d7e9c0d2960bc2a3437ee5369f447ead860f1fL
//Plaintext    =  0x805a046dd9eef68f63235d226b1571a3371026f2ecdf1f6c96a63d1d0f7bc0787398fcffeb32eb1c1934636b81e74b325f32031ef50f7b3402f7c88392606c0a441aac9f6d974046312738ba882648c68fd3bd15cd851c50b91d7dfc62223df44caf5d6b802846fc7ef43a90e50a4507437facdee196fdaca0b8caeb3b990a79L

//--- Execute RSA in HW (slow)
//Ciphertext   =  0x120dfce55cb49d828dccca637e756c361f603a280929239ddd91c188bc91a10d8bb7adcea555748123d4d4fa4c9ae5a1e4fcd834ccd504e8eec9433ffff6e1ceaa2c9e5f4d584f668e6346d458aa7677e8322c03c2358f46f339d38e75ea6d7e911f7122e1865acad95e9ff1f4d7e9c0d2960bc2a3437ee5369f447ead860f1fL
//Plaintext    =  0x805a046dd9eef68f63235d226b1571a3371026f2ecdf1f6c96a63d1d0f7bc0787398fcffeb32eb1c1934636b81e74b325f32031ef50f7b3402f7c88392606c0a441aac9f6d974046312738ba882648c68fd3bd15cd851c50b91d7dfc62223df44caf5d6b802846fc7ef43a90e50a4507437facdee196fdaca0b8caeb3b990a79L
    
$display("Test for seed 2018.4");
                                
input_data <= 1024'h805a046dd9eef68f63235d226b1571a3371026f2ecdf1f6c96a63d1d0f7bc0787398fcffeb32eb1c1934636b81e74b325f32031ef50f7b3402f7c88392606c0a441aac9f6d974046312738ba882648c68fd3bd15cd851c50b91d7dfc62223df44caf5d6b802846fc7ef43a90e50a4507437facdee196fdaca0b8caeb3b990a79;
send_cmd_to_hw(CMD_READ_X);
send_data_to_hw(input_data);
waitdone();
                        
input_data <= 1024'hc78b;
send_cmd_to_hw(CMD_READ_E);
send_data_to_hw(input_data);
waitdone();
                        
input_data <= 1024'h8893eaa14f8842183be9e214982cce482f5a0d0337799ea628ad9a7fdb1a87c764c81c6087363b2f94a2095825e93a2b0a248074f6e3ef1dd55572d525cebe7dd3f2e70c77db25787bdb48dafddc05282a38b3f51add7adfc72566e25d3a7853c5b7054ef5e4cc2409f8351c5c7c3c22bae297ec72162a0513c64942cb601e03;
send_cmd_to_hw(CMD_READ_M);
send_data_to_hw(input_data);
waitdone();
                        
input_data <= 1024'h776c155eb077bde7c4161deb67d331b7d0a5f2fcc8866159d752658024e578389b37e39f78c9c4d06b5df6a7da16c5d4f5db7f8b091c10e22aaa8d2ada3141822c0d18f38824da878424b7250223fad7d5c74c0ae522852038da991da2c587ac3a48fab10a1b33dbf607cae3a383c3dd451d68138de9d5faec39b6bd349fe1fd;
send_cmd_to_hw(CMD_READ_R);
send_data_to_hw(input_data);
waitdone();
                        
input_data <= 1024'h39af459d4e0f097f06bc11391c5ce74a1f830b576458313ef8f5de3f69f82b0e8400413acbad7561cc931269a19b6f997d8099d53fc9db5a29bc66062a40fc2769e7cb13e26553a62c250c832d232e00021d20e9192ecb85268bb76700a75f2faf246df2d1cbcac294d751555b3acfb908adae3e0b0f86b6e9f78769328c7973;
send_cmd_to_hw(CMD_READ_R2);
send_data_to_hw(input_data);
waitdone();
                
// Encryption
expected <= 1024'h120dfce55cb49d828dccca637e756c361f603a280929239ddd91c188bc91a10d8bb7adcea555748123d4d4fa4c9ae5a1e4fcd834ccd504e8eec9433ffff6e1ceaa2c9e5f4d584f668e6346d458aa7677e8322c03c2358f46f339d38e75ea6d7e911f7122e1865acad95e9ff1f4d7e9c0d2960bc2a3437ee5369f447ead860f1f;
                
compute_command(10'd16, compute_cmd);
send_cmd_to_hw(compute_cmd);
waitdone();
                
// Read result
send_cmd_to_hw(CMD_WRITE_RESULT);
read_data_from_hw(output_data);
waitdone();
                        
result_ok <= (expected == output_data);
if (expected == output_data)
    $display("Encryption is correct.");
$display("Encoded ciphertext is      %h", output_data);
                     
// Decryption
input_data <= expected;
send_cmd_to_hw(CMD_READ_X);
send_data_to_hw(input_data);
waitdone();
                                        
input_data <= 1024'h34203761dc2586c7bdb9874fa3734826beebc8b547de61551b5e3262929a461cc5b67ceea35106bed32f2a624c7bda55a3261e1d380fc90874a31eb08b42e53c2d65fe783b68b5201a67db6c872aa2ea8861aa8fee1831060d328b60165968878995efaff300d009ea3705b6d4f42be5bbf9d4f2d900fcaf7713c4c58853c5cd;
send_cmd_to_hw(CMD_READ_E);
send_data_to_hw(input_data);
waitdone();
                                
// Compute decryption
expected <= 1024'h805a046dd9eef68f63235d226b1571a3371026f2ecdf1f6c96a63d1d0f7bc0787398fcffeb32eb1c1934636b81e74b325f32031ef50f7b3402f7c88392606c0a441aac9f6d974046312738ba882648c68fd3bd15cd851c50b91d7dfc62223df44caf5d6b802846fc7ef43a90e50a4507437facdee196fdaca0b8caeb3b990a79;
                          
compute_command(10'd1022, compute_cmd);
send_cmd_to_hw(compute_cmd);
waitdone();
                                
send_cmd_to_hw(CMD_WRITE_RESULT);
read_data_from_hw(output_data);
waitdone();
                                      
result_ok <= (expected == output_data);
if (expected == output_data)
    $display("Decryption is correct.");             
$display("Decoded plaintext is      %h", output_data);

#`CLK_PERIOD;

// Seed 2018.5 test

//--- Precomputed Values
//p            =  0x9c0eeb23f6c957bc78baeadef6cf3ae371add7a4426696a0602c8bbc732f3e4e08b2ba2d3453aa7ca37405781edf0a4f173f7f0337b020a577b29a4c40e3bfa9L
//q            =  0xf0d72585d5e550b31a3456d3344038d26930b2af174ba1289ef29df23e489cdcd231dd201a7585baaff1daf8e8ce21706f73ec6706cfaa3cbbc7b5316eac7933L
//Modulus      =  0x92d123d8f0b195e2cc25cec0f9733760ee8c4fb0d7345ca84f45f13a7ff30b59b88879bf5fa840b74cd045f586c21117e501b14f8daedecee7e59f37b9e27529b6289e244858dfea27d15f156da2ed18217682f8cb0012a2be00955a333b98e054b27b7136ce2708139245e482f649e1715e2fc7976246f694196994f6820fabL
//Enc exp      =  0xf9a9
//Dec exp      =  0x75e26ef578473a885c8a53ee2ac62cc5168d8e6089acf1f8406364d7354fd81855cda8df4052540ff9c8b622c6eeef9fb98e464d9745f94bd86324c9241c8addc4b935667398d9da7f0cc10af4362a344c011f6c12f330a66c989353a5be875b5d09d88f29708ba21b14f59a0f42b31be8e9328ef8e3d5c563494b6534c94b79L
//Message      =  0x8b7f895d5ecb16069791fb913b9b49c1434a941605fe1b0911b77992b63b0051cb999aa8f7222db38d8bc1d29ec4e322901253f584e59a97c5637c4de79d9fa294aca08b2e0bc30e39f47eede7ff41aee93763e1cd28d36ab4c2ff8f205df65a026c1296161bf309cd1dd5788eb793f1c16f213baf32aa32a640212b5457cd38L

//--- Execute RSA (for verification)
//Ciphertext   =  0x43ab79c005c86a9aa186180acc91fdd849f4ba2de21c4423d897418d4420709ab138c74b9e1b9520f3fef70cb34b6a8b1ee60d0d6780afd07c4edb2e596742b8d228d6652cd544ca4d46cab3b38f5d8bb1e97970c72d1ff33c55bad33d456c8d517803ce626ad5e3668a6fa92075e24a048c9f19b173976272afb066f8ebc310L
//Plaintext    =  0x8b7f895d5ecb16069791fb913b9b49c1434a941605fe1b0911b77992b63b0051cb999aa8f7222db38d8bc1d29ec4e322901253f584e59a97c5637c4de79d9fa294aca08b2e0bc30e39f47eede7ff41aee93763e1cd28d36ab4c2ff8f205df65a026c1296161bf309cd1dd5788eb793f1c16f213baf32aa32a640212b5457cd38L

//--- Execute RSA in HW (slow)
//Ciphertext   =  0x43ab79c005c86a9aa186180acc91fdd849f4ba2de21c4423d897418d4420709ab138c74b9e1b9520f3fef70cb34b6a8b1ee60d0d6780afd07c4edb2e596742b8d228d6652cd544ca4d46cab3b38f5d8bb1e97970c72d1ff33c55bad33d456c8d517803ce626ad5e3668a6fa92075e24a048c9f19b173976272afb066f8ebc310L
//Plaintext    =  0x8b7f895d5ecb16069791fb913b9b49c1434a941605fe1b0911b77992b63b0051cb999aa8f7222db38d8bc1d29ec4e322901253f584e59a97c5637c4de79d9fa294aca08b2e0bc30e39f47eede7ff41aee93763e1cd28d36ab4c2ff8f205df65a026c1296161bf309cd1dd5788eb793f1c16f213baf32aa32a640212b5457cd38L

$display("Test for seed 2018.5");
                                
input_data <= 1024'h8b7f895d5ecb16069791fb913b9b49c1434a941605fe1b0911b77992b63b0051cb999aa8f7222db38d8bc1d29ec4e322901253f584e59a97c5637c4de79d9fa294aca08b2e0bc30e39f47eede7ff41aee93763e1cd28d36ab4c2ff8f205df65a026c1296161bf309cd1dd5788eb793f1c16f213baf32aa32a640212b5457cd38;
send_cmd_to_hw(CMD_READ_X);
send_data_to_hw(input_data);
waitdone();
                        
input_data <= 1024'h959f;
send_cmd_to_hw(CMD_READ_E);
send_data_to_hw(input_data);
waitdone();
                        
input_data <= 1024'h92d123d8f0b195e2cc25cec0f9733760ee8c4fb0d7345ca84f45f13a7ff30b59b88879bf5fa840b74cd045f586c21117e501b14f8daedecee7e59f37b9e27529b6289e244858dfea27d15f156da2ed18217682f8cb0012a2be00955a333b98e054b27b7136ce2708139245e482f649e1715e2fc7976246f694196994f6820fab;
send_cmd_to_hw(CMD_READ_M);
send_data_to_hw(input_data);
waitdone();
                        
input_data <= 1024'h6d2edc270f4e6a1d33da313f068cc89f1173b04f28cba357b0ba0ec5800cf4a647778640a057bf48b32fba0a793deee81afe4eb072512131181a60c8461d8ad649d761dbb7a72015d82ea0ea925d12e7de897d0734ffed5d41ff6aa5ccc4671fab4d848ec931d8f7ec6dba1b7d09b61e8ea1d038689db9096be6966b097df055;
send_cmd_to_hw(CMD_READ_R);
send_data_to_hw(input_data);
waitdone();
                        
input_data <= 1024'he09d633f4f0163c80fc66b985beac5644b4e1006b326707dcc4a8803c397fb1e37978120019901d45d3ab7173d258b263ff514f0e28035a5002c8e551b330f864e4fc80633b8a289963baab14f3a04bffc33bd610e58ea05a7520bec52d13cd74f48dbc6ecf13cf600165505bc9a13e72e2964fd33dd515acfd702e48d97129;
send_cmd_to_hw(CMD_READ_R2);
send_data_to_hw(input_data);
waitdone();
                
// Encryption
expected <= 1024'h43ab79c005c86a9aa186180acc91fdd849f4ba2de21c4423d897418d4420709ab138c74b9e1b9520f3fef70cb34b6a8b1ee60d0d6780afd07c4edb2e596742b8d228d6652cd544ca4d46cab3b38f5d8bb1e97970c72d1ff33c55bad33d456c8d517803ce626ad5e3668a6fa92075e24a048c9f19b173976272afb066f8ebc310;
                
compute_command(10'd16, compute_cmd);
send_cmd_to_hw(compute_cmd);
waitdone();
                
// Read result
send_cmd_to_hw(CMD_WRITE_RESULT);
read_data_from_hw(output_data);
waitdone();
                        
result_ok <= (expected == output_data);
if (expected == output_data)
    $display("Encryption is correct.");
$display("Encoded ciphertext is      %h", output_data);
                       
// Decryption
input_data <= expected;
send_cmd_to_hw(CMD_READ_X);
send_data_to_hw(input_data);
waitdone();
                                        
input_data <= 1024'h4f6949965369496351d5e38fb8a64b8bec66a1782cd7946c22e8874a788dc85d6d70bed2e5648c9b328667a41b7c4019162a3617a841987f2dcd8ce733564e91dda89c124992630de94fd174d93138cefcfbbbb1a23689cff81525017d8ad9d50c0df956759363010fc79ac88338d8b4519a31aa3be5289d08ae710f57bb23d7;
send_cmd_to_hw(CMD_READ_E);
send_data_to_hw(input_data);
waitdone();
                                
// Compute decryption
expected <= 1024'h8b7f895d5ecb16069791fb913b9b49c1434a941605fe1b0911b77992b63b0051cb999aa8f7222db38d8bc1d29ec4e322901253f584e59a97c5637c4de79d9fa294aca08b2e0bc30e39f47eede7ff41aee93763e1cd28d36ab4c2ff8f205df65a026c1296161bf309cd1dd5788eb793f1c16f213baf32aa32a640212b5457cd38;
                          
compute_command(10'd1023, compute_cmd);
send_cmd_to_hw(compute_cmd);
waitdone();
                                
send_cmd_to_hw(CMD_WRITE_RESULT);
read_data_from_hw(output_data);
waitdone();
                                      
result_ok <= (expected == output_data);
if (expected == output_data)
    $display("Decryption is correct.");        
$display("Decoded plaintext is      %h", output_data);

#`CLK_PERIOD;
        
        #`CLK_PERIOD;
                       
        $finish;
    end
endmodule