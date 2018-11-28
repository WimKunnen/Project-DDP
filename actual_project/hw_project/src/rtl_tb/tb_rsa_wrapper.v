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

    localparam CMD_COMPUTE          = 32'h0;
    localparam CMD_WRITE            = 32'h2;
    localparam CMD_READ_X           = 32'h1;
    localparam CMD_READ_E           = 32'h3;
    localparam CMD_READ_R           = 32'h5;
    localparam CMD_READ_R2          = 32'h7;
    localparam CMD_READ_M           = 32'h9;   
    
    initial begin

        #`RESET_TIME
        result_ok <= 0;
        
        // Your task: 
        // Design a testbench to test your accelerator using the tasks defined above: send_cmd_to_hw, send_data_to_hw, read_data_from_hw, waitdone
        
        input_data  <= 1024'h00000000000000000123456789abcdef00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
        output_data <= 1024'b0;
        
        #`CLK_PERIOD;

        ///////////////////// START EXAMPLE  /////////////////////
        
        //// --- Send the read command and transfer input data to FPGA

        $display("Test for input %h", input_data);
                
        $display("Sending read x, e command");
        input_data <= 1024'ha3935ce177636f9ee4e64e8f247296b391dbeba9e29b81ba16396f5d83ea4414bc97ffdc39026a2371538811c3df998b5fed827baa5a032d723676eedb5dd43cf46405c28e6681c3229f74542040a7a025a4de17ca9980ea569fb01e3c4384f23ba7ca66aa85c7720d86e96905133c761fffb07f08e1b39e8649697d7a884221;
        send_cmd_to_hw(CMD_READ_X);
        send_data_to_hw(input_data);
        waitdone();
        input_data <= 1024'h904f;
        send_cmd_to_hw(CMD_READ_E);
        send_data_to_hw(input_data);
        waitdone();
        
        $display("Sending read m, r, r2 command");
        input_data <= 1024'hd6caa56f9ac67cf3932698b1c068d9252fe3483e00e33f3bb0a6b6faf9f25cfb23749d2ac5da383b7a454d3580621814a05504fed95e18c6af8fcad44080e42a3c2d4832e0548ca5f48b44d5fec2f34a5e135748e8312392c45f644048a79a66c64333caa6cf0cf313c461e4e017ed1640cfde4e6076f0440a3a596e8c9d096b;
        send_cmd_to_hw(CMD_READ_M);
        send_data_to_hw(input_data);
        waitdone();
        input_data <= 1024'h29355a906539830c6cd9674e3f9726dad01cb7c1ff1cc0c44f594905060da304dc8b62d53a25c7c485bab2ca7f9de7eb5faafb0126a1e7395070352bbf7f1bd5c3d2b7cd1fab735a0b74bb2a013d0cb5a1eca8b717cedc6d3ba09bbfb758659939bccc355930f30cec3b9e1b1fe812e9bf3021b19f890fbbf5c5a6917362f695;
        send_cmd_to_hw(CMD_READ_R);
        send_data_to_hw(input_data);
        waitdone();
        input_data <= 1024'hb243e11d7992baebf34d6b3b22cc7f79b9acc20c23ec8692a8c42e64d159463dc83e99b358878212e49ec9c2ef4f9c32bba05826df631a507a6121524d3d1914e1c771058a19b62773d9ea4e8dfaa74c5a36c8e0d696870f4f571f7ed5386a43fc50322897f5cb1ab4eda146b847decb284096240f456964447fe6d8e14a3049;
        send_cmd_to_hw(CMD_READ_R2);
        send_data_to_hw(input_data);
        waitdone();

        //// --- Perform the compute operation
        expected <= 1024'h7b372b2b2b599c3521461a30464cba185022509950503acf41b533fd6a1762169561898acf750117c64a34a9636230792c33177d869e92069faf74ab35a49dead93a31a0dfa9686d24b05a1ae168dd21cf7ba14811f11e9d4552f3b697c3bb6becc40123c407e1a8fc0881b500df15472e8418d5e21eef405c80a5691e0fc16d;

        $display("Sending compute command");
        compute_command(10'd16, compute_cmd);
        send_cmd_to_hw(compute_cmd);
        waitdone();

	    //// --- Send write command and transfer output data from FPGA
        
        $display("Sending write command");
        send_cmd_to_hw(CMD_WRITE);
        read_data_from_hw(output_data);
        waitdone();
        
        result_ok <= (expected == output_data);
        #`CLK_PERIOD;
        #`CLK_PERIOD;
        #`CLK_PERIOD;

        //// --- Print the array contents

        $display("Output is      %h", output_data);
                  
        ///////////////////// END EXAMPLE  /////////////////////  
        
        $finish;
    end
endmodule