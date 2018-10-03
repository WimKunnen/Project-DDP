`timescale 1ns / 1ps

module hweval_montgomery(
    input   clk     ,
    input   resetn  ,
    output  data_ok );

    reg          start;
    reg  [511:0] in_a;
    reg  [511:0] in_b;
    reg  [511:0] in_m;
    wire [511:0] result;
    wire         done;
    
    //Instantiating montgomery module
    montgomery montgomery_instance( .clk    (clk      ),
                                    .resetn (resetn   ),
                                    .start  (start    ),
                                    .in_a   (in_a     ),
                                    .in_b   (in_b     ),
                                    .in_m   (in_m     ),
                                    .result (result   ),
                                    .done   (done     ));

    reg [1:0] state;

    always @(posedge(clk)) begin
    
        if (!resetn) begin
            in_a     <= 1027'b1;
            in_b     <= 1027'b1;
            in_m     <= 1027'h6fb734834375c10c35cd8b58baecd83e32a5249d46f5ff6def02094d2a8733ddd742f92c882b522402700bd74004776e7498e7545abccda330761b80d520326d8762484d6b60908f74f31fd320bb8b6cc5cef91632e1a4bac9b7b946602af8bb662889e6e8ed52c178506c1f3a064581c926c23b8ff85c247827b578aff2ef518;
                    
            start    <= 1'b0;           
            
            state    <= 2'b00;
        end else begin
    
            if (state == 2'b00) begin
                in_a     <= in_a;
                in_b     <= in_b;
                in_m     <= in_m;     
                
                start    <= 1'b1;            
                
                state    <= 2'b01;        
            
            end else if(state == 2'b01) begin
                in_a     <= in_a;
                in_b     <= in_b;
                in_m     <= in_m;
                        
                start    <= 1'b0;           
                
                state    <= done ? 2'b10 : 2'b01;
            end
            
            else begin
                in_a     <= in_b ^ result[1026:0];
                in_b     <= result[1026:0];
                in_m     <= in_m;
                                    
                start    <= 1'b0;
                            
                state    <= 2'b00;
            end
        end
    end    
    
    assign data_ok = done & result[1026];
    
endmodule