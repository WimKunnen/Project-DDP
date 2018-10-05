`timescale 1ns / 1ps

`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_adder();

    // Define internal regs and wires
    reg           clk;
    reg           resetn;
    reg  [1027:0] in_a;
    reg  [1027:0] in_b;
    reg           start;
    reg           subtract;
    reg           shift;
    wire [1028:0] result;
    wire          done;

    reg  [1028:0] expected;
    reg           result_ok;

    // Instantiating adder
    adder dut (
        .clk      (clk     ),
        .resetn   (resetn  ),
        .start    (start   ),
        .subtract (subtract),
        .shift    (shift   ),
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
        shift    <= 0;
        start    <= 0;
    end

    // Reset the circuit
    initial begin
        resetn = 0;
        #`RESET_TIME
        resetn = 1;
    end

    task perform_add;
        input [1027:0] a;
        input [1027:0] b;
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
        input [1027:0] a;
        input [1027:0] b;
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
    perform_add(1027'h26cabac64f8573fc11798243176c861695c2e41c76022b91b1bcf50c0e5fe57945bba72cc65bec65fdb51b08218e98a93be857e4e6deb90b2841e3ac65bc72386,
                1027'h2a34bae83b7fa781f7ecde7753f30cbc6df7d94c0ba8c0f29168fcd5fcb4e4534e722e0e2c17a57987f160d456c324f6c6b462fec4968aa8b01812c506425a16a);
    expected  = 1028'h50ff75ae8b051b7e096660ba6b5f92d303babd6881aaec844325f1e20b14c9cc942dd53af27391df85a67bdc7851bda0029cbae3ab7543b3d859f6716bfecc4f0;
    wait (done==1);
    result_ok = (expected==result);
    #`CLK_PERIOD;     
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    
    // Test shifting as well
    #`CLK_PERIOD;    
    shift <= 1'b1;
    #`CLK_PERIOD; 
    shift <= 1'b0;
    $display("result shifted   =%x", result);
    #`CLK_PERIOD; 
    
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
    perform_sub(1027'h3f12eadac849c11b2eb390a6b1bcf40c50b17adfad30c0a4eb67edbff025236192bdf0812cb0c55e0a8438b92832b3a4c0dd2cb402cc03e904ac73b5c8b63c139,
                1027'h3f6837b7c0df55b0bcf48bdb6d38065def3cc5a9eb6815c478763ad5e4586d589c67cd2831b47bec5ae6ff7f6c4f0556435258da313acd48b125bef74ef276754);
    expected  = 1028'h7faab323076a6b6a71bf04cb4484edae6174b535c1c8aae072f1b2ea0bccb608f6562358fafc4971af9d3939bbe3ae4e7d8ad3d9d19136a05386b4be79c3c59e5;
    wait (done==1);
    result_ok = (expected==result);
    #`CLK_PERIOD;    
    $display("result calculated=%x", result);
    $display("result expected  =%x", expected);
    $display("error            =%x", expected-result);
    
    // Test shifting as well
    #`CLK_PERIOD;    
    shift <= 1'b1;
    #`CLK_PERIOD; 
    shift <= 1'b0;
    $display("result shifted   =%x", result);
    #`CLK_PERIOD; 
    
    $display("\n");
    
    #`CLK_PERIOD;     

    $finish;

    end

endmodule