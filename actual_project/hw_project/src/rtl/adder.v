`timescale 1ns / 1ps

module mpadder(
    input  wire          clk,
    input  wire          resetn,
    input  wire          start,
    input  wire          subtract,
    input  wire [1026:0] in_a,
    input  wire [1026:0] in_b,
    output wire [1027:0] result,
    output wire          done    
    );

    wire [172:0] adder_result;
    // [1] is with carry = 1, [0] is with catty = 0
    wire [172:0] predicted_adder_result[1:0];

    // in_a mux
    reg input_mux_sel;
    reg [1031:0] a;
    
    wire [172:0] predicted_mux;
    wire [1031:0] a_mux;
    assign predicted_mux = adder_result[172] == 1 ? predicted_adder_result[1] : predicted_adder_result[0];
    assign a_mux = (input_mux_sel == 1) ? {5'b0, in_a} : {predicted_mux[171:0], adder_result[171:0], a[1031:344]}; 
    
    // in_b mux
    reg [1031:0] b;
    wire [1031:0] b_mux;   

    assign b_mux = (input_mux_sel == 1) ? ( subtract == 1 ? {5'b11111, ~in_b} : {5'b0, in_b}) : {344'b0, b[1029:344]};
    
    // input registers
    reg input_enable;
    	
    always @(posedge clk)
    begin
        if(resetn == 0)
        begin
            a <= 1032'b0;
            b <= 1032'b0;
        end
        else if(input_enable == 1)
        begin
            a <= a_mux;
            b <= b_mux;
        end
    end

    // add/subtract register
    reg sub;
    always @(posedge clk)
    begin
        if(resetn == 0)
            sub <= 0;
        else
            sub <= subtract;
    end
    
    // adder
    wire carry_in;
    wire carry_mux;
    reg carry_reg;
    
    assign carry_in = carry_reg;
    assign adder_result = a[171:0] + b[171:0] + carry_in;
    assign predicted_adder_result[0] = a[343:172] + b[343:172];
    assign predicted_adder_result[1] = a[343:172] + b[343:172] + 1;
        
    // carry register
    assign carry_mux = (start == 1) ? subtract : (adder_result[172] == 1 ? predicted_adder_result[1][172] : predicted_adder_result[0][172]);
   
    always @(posedge clk)
    begin
        if (resetn == 0)
            carry_reg <= 0;
        else
            carry_reg <= carry_mux;
    end
    
    // Assign output
    assign result = a[1027:0];
    
    // FSM
    reg [1:0] state, nextstate;
    
    always @(posedge clk)
    begin
        if(resetn==0)
            state <= 2'd0;
        else
            state <= nextstate;
    end
    
    // Add cycle counter
    reg count_enable;
    reg [1:0] counter;
    always @(posedge clk)
    begin
        if (resetn == 0)
            counter <= 0;
        else if (state == 2'd3)
            counter <= 0;
        else if (count_enable == 1)
            counter <= counter + 1;
    end

    always @(*)
    begin
        case(state)
            // Idle state
            2'd0: begin
                input_mux_sel <= 1'b1;
                input_enable <= 1'b1;
                count_enable <= 1'b0;
            end
            // Add state
            2'd1: begin
                input_mux_sel <= 1'b0;
                input_enable <= 1'b1;
                count_enable <= 1'b1;
            end
            // Sub state
            2'd2: begin
                input_mux_sel <= 1'b0;
                input_enable <= 1'b1;
                count_enable <= 1'b1;
            end
            // Done state
            2'd3: begin
                input_mux_sel <= 1'b1;
                input_enable <= 1'b0;
                count_enable <= 1'b0;
           end
        endcase
    end
    
    // Done signal
    reg done_reg;
    always @(posedge clk)
    begin
    if(resetn == 0)
        done_reg <= 0;
    else if (counter == 2)
        done_reg <= 1;
    else 
        done_reg <= 0;
    end
    assign done = done_reg;
    
    always @(*)
        begin
            case(state)
                2'd0: begin
                    if(start)
                        nextstate <= 2'd1;
                    else
                        nextstate <= 2'd0;
                    end
                2'd1: begin
                    if (counter == 2)
                        nextstate <= 2'd3;
                    else
                        nextstate <= state;
                end
                2'd2: begin
                    if (counter == 2)
                        nextstate <= 2'd3;
                    else
                        nextstate <= state;
                end
                2'd3: begin
                    nextstate <= 2'd0;
                end
                default: nextstate <= 2'd0;
            endcase
        end
endmodule