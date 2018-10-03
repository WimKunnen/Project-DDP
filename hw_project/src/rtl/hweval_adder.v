`timescale 1ns / 1ps

module hweval_adder (
    input   clk     ,
    input   resetn  ,
    output  data_ok );

    reg           start;
    reg           subtract;
    reg  [1026:0] in_a;
    reg  [1026:0] in_b;
    wire [1027:0] result;
    wire          done;
       
    // Instantiate the adder    
    mpadder dut (
        .clk      (clk     ),
        .resetn   (resetn  ),
        .start    (start   ),
        .subtract (subtract),
        .in_a     (in_a    ),
        .in_b     (in_b    ),
        .result   (result  ),
        .done     (done    ));

    reg [1:0] state;

    always @(posedge(clk)) begin
    
        if (!resetn) begin
            in_a     <= 1027'b1;
            in_b     <= 1027'b1;
            subtract <= 1'b0;
                    
            start    <= 1'b0;           
            
            state    <= 2'b00;
        end else begin
    
            if (state == 2'b00) begin
                in_a     <= in_a;
                in_b     <= in_b;
                subtract <= subtract;
                
                start    <= 1'b1;            
                
                state    <= 2'b01;        
            
            end else if(state == 2'b01) begin
                in_a     <= in_a;
                in_b     <= in_b;
                subtract <= subtract;
                        
                start    <= 1'b0;           
                
                state    <= done ? 2'b10 : 2'b01;
            end
            
            else begin
                in_a     <= in_b ^ result[1026:0];
                in_b     <= result[1026:0];
                subtract <= result[1026];
                                    
                start    <= 1'b0;
                            
                state    <= 2'b00;
            end
        end
    end    
    
    assign data_ok = done & result[1026];
    
endmodule