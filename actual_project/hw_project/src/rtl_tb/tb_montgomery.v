`timescale 1ns / 1ps

`define RESET_TIME 25
`define CLK_PERIOD 10
`define CLK_HALF 5

module tb_montgomery();
    
    reg          clk;
    reg          resetn;
    reg          start;
    reg  [1023:0] in_a;
    reg  [1023:0] in_b;
    reg  [1023:0] in_m;
    wire [1023:0] result;
    wire         done;

    reg  [1023:0] expected;
    reg          result_ok;
    
    //Instantiating montgomery module
    montgomery montgomery_instance( .clk    (clk    ),
                                    .resetn (resetn ),
                                    .start  (start  ),
                                    .in_a   (in_a   ),
                                    .in_b   (in_b   ),
                                    .in_m   (in_m   ),
                                    .result (result ),
                                    .done   (done   ));

    //Generate a clock
    initial begin
        clk = 0;
        forever #`CLK_HALF clk = ~clk;
    end
    
    //Reset
    initial begin
        resetn = 0;
        #`RESET_TIME resetn = 1;
    end
    
    // Test data
    initial begin

        #`RESET_TIME
        
        // You can generate your own with test vector generator python script
        in_a     <= 1024'h8e328b92e9180b446fb7739d3f567ef301e992679c089b20eba45a7c83484997c68b2f484fc3bb95cd783958fcabac9fd55265dc61ec5d10c78cc4172c1e0260b23da69a1de10c16bb78418a93d10569f241273446ca2879e8ccbe98ad5b42befa7d60ce94225174b5f4ac0c77d18fe5f6c2d8aa3fe12021ff95cab0cb8d22da;
        in_b     <= 1024'ha31e9037659fd5251c917ee329b30020e2ef2b55fab203ee8dba6fea2d396cfa97fd70d5d063e5a7b2d8caa1fecd147dd0b81e1f0431efbd1d764a8d5fba443c0f6f9ce5ed658dbae8ad4bf63f87a0d457d7a218953e363c9c004181d46a91d5de206a7254fc0370017f37b79a2ecdb925e2c971cdd959d288d67ae6ff8bcb66;
        in_m     <= 1024'haa9f14ab61978f1426e03f0e87fd2de456afcd407017a58966d8bf31cc9aebf5d5586d79bc2e829f2a6ba3021a50f710d175bb98f5b797f345fd503bb2a1057c88b82025a8a1b4f049d44e25926ef8e6a660ea9a910016d390f1a2ec56505ce7ab214a577291ecb5dc93109d9ba755dbec8e22d89e4733505c564c21c2cfcd31;
        expected <= 1024'h3b6dd06956748c37ab4c4a0c56be8251d75b067f6c121195d637e267d61215e173744ada49b0237400bd0bdf1e244bc196164dac3db591fa3344a474d8c935527005763fdd2c6c5f858923c36127d3f33d27841eabcb1b85db2d37a5482bc167081d065149ba6acdafc0b5d102b2135810c7f0051c15d2cbfb3ff38ac8498c5d;
        
        start<=1;
        #`CLK_PERIOD;
        start<=0;
        
        wait (done==1);
        #`CLK_PERIOD;   
        
        $display("result calculated=%x", result);
        $display("result expected  =%x", expected);
        $display("error            =%x", expected-result);
        result_ok = (expected==result);
        #`CLK_PERIOD; 
        #`CLK_PERIOD; 
        $finish;
    end
           
endmodule