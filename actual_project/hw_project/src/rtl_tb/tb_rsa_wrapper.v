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

        // Compute
        expected <= 1024'h1c1f19b8a6bef4e86bf8574df7b576cfc8d2f79010eae22f0e4a6c11fa34def6dcc19b0204f3cfb17f8735d364aa2aec61b3d0015d5a17f6eb6008daf85af4c184eea3de7e0d87e2447a540cada80aca352c7cfac809b7257aa646005f1f3611846dc881c9e0bee49ce09f59fba086a60a86e8e183bd1d82bdafaea75d183991;

        compute_command(10'd16, compute_cmd);
        send_cmd_to_hw(compute_cmd);
        waitdone();

	    // Read result
        send_cmd_to_hw(CMD_WRITE_RESULT);
        read_data_from_hw(output_data);
        waitdone();
        
        result_ok <= (expected == output_data);

        //// Print the result.
        $display("Output is      %h", output_data);
        
        #`CLK_PERIOD;
        #`CLK_PERIOD;
               
        ///////////////////// END EXAMPLE  /////////////////////  
        
        $finish;
    end
endmodule