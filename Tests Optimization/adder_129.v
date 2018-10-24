`timescale 1ns / 1ps

//adder width = 129
//number of adders = 1
//cycles to perform 1027-bit = 8
//WNS = 1.884 ns
//Slice LUTs = 2352
//Flip Flops = 5183
//LUT usage (%) = 13.36
//Flip Flop usage (%) = 14.72 


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
//    always @(posedge(clk))
//        result = in_a + in_b;
    
//    assign done = 1'b1;

    // in_a mux
    reg input_mux_sel;
    reg [1031:0] a_reg;
    wire [1026:0] a_mux_out;
    assign a_mux_out = (input_mux_sel == 1) ? {5'b0, in_a} : {129'b0, a_reg[1031:129]};
    
    // in_b mux
    reg [1031:0] b_reg;
    wire [1026:0] b_mux_out;
    assign b_mux_out = (input_mux_sel == 1) ? {5'b0, in_b} : {129'b0, b_reg[1031:129]};
    
    // input registers
    reg input_enable;
    always @(posedge clk)
    begin
        if(resetn == 0)
        begin
            a_reg <= 1032'b0;
            b_reg <= 1032'b0;
        end
        else if(input_enable == 1)
        begin
            a_reg <= a_mux_out;
            b_reg <= b_mux_out;
        end
    end

    // add/sub mux
    reg sub;
    always @(posedge clk)
    begin
        if(resetn == 0)
            sub <= 0;
        else
            sub <= subtract;
    end
    
    wire [128:0] add_sub_mux;
    assign add_sub_mux = (sub == 1) ? ~b_reg[128:0] : b_reg[128:0];
    
    // adder
    wire carry_in;
    wire [129:0] temp_result;
    assign carry_in = carry_reg;
    assign temp_result = a_reg[128:0] + add_sub_mux[128:0] + carry_in;
    
    // carry register
    wire carry_mux;
    reg carry_reg;
    assign carry_mux = (start == 1) ? subtract : temp_result[129];
   
    always @(posedge clk)
    begin
        if (resetn == 0)
            carry_reg <= 0;
        else
            carry_reg <= carry_mux;
    end
    
    // output register
    reg out_enable;
    reg [1031:0] out;
    assign result = out[1027:0];
    
    always @(posedge clk)
    begin
        if (resetn == 0)
            out <= 1031'b0;
        else if (out_enable == 1)
            out <= {temp_result, out[1031:129]};
    end
    
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
    reg [2:0] counter;
    always @(posedge clk)
    begin
        if (resetn == 0)
            counter <= 3'd0;
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
                out_enable <= 1'b0;
            end
            // Add state
            2'd1: begin
                input_mux_sel <= 1'b0;
                input_enable <= 1'b1;
                count_enable <= 1'b1;
                out_enable <= 1'b1;
            end
            // Sub state
            2'd2: begin
                input_mux_sel <= 1'b1;
                input_enable <= 1'b0;
                count_enable <= 1'b1;
                out_enable <= 1'b0;
            end
            // Done state
            2'd3: begin
                input_mux_sel <= 1'b1;
                input_enable <= 1'b0;
                count_enable <= 1'b0;
                out_enable <= 1'b0;
           end
        endcase
    end
    
    // Done signal
    reg done_reg;
    always @(posedge clk)
    begin
    if(resetn == 0)
        done_reg <= 0;
    else if (state == 2'd3)
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
                    if (counter == 7)
                        nextstate <= 2'd3;
                    else
                        nextstate <= state;
                end
                2'd2: begin
                    if (counter == 7)
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
