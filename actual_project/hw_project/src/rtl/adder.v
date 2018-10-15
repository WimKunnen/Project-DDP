`timescale 1ns / 1ps

//adder width = 172
//number of adders = 3
//cycles to perform 1027-bit = 3
//WNS = 0.806 ns
//Slice LUTs = 2805
//Flip Flops = 4690
//LUT usage (%) = 15.94
//Flip Flop usage (%) = 13.32

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

    wire [257:0] temp_result1;
    wire [257:0] temp_result2;
    wire [257:0] temp_result3;

    // in_a mux
    reg input_mux_sel;
    reg [515:0] a1_reg;
    reg [515:0] a2_reg;
    reg [515:0] a3_reg;
    wire [515:0] a1_mux_out;
    wire [515:0] a2_mux_out;
    wire [515:0] a3_mux_out;
    assign a1_mux_out = (input_mux_sel == 1) ? (start == 1 ? {in_a[515:0]} : a1_reg) : {temp_result1[171:0], a1_reg[515:172]};
    assign a2_mux_out = (input_mux_sel == 1) ? (start == 1 ? {5'b0, in_a[1026:516]} : a2_reg) : {temp_result2[171:0], a2_reg[515:172]};
    assign a3_mux_out = (input_mux_sel == 1) ? (start == 1 ? {5'b0, in_a[1026:516]} : a3_reg) : {temp_result3[171:0], a3_reg[515:172]};
    
    // in_b mux  
    reg [515:0] b1_reg;
    reg [515:0] b2_reg;
    reg [515:0] b3_reg;
    wire [515:0] b1_mux_out;
    wire [515:0] b2_mux_out;
    wire [515:0] b3_mux_out;
    assign b1_mux_out = (input_mux_sel == 1) ? {in_b[515:0]} : {172'b0, b1_reg[515:172]};
    assign b2_mux_out = (input_mux_sel == 1) ? {5'b0, in_b[1026:516]} : {172'b0, b2_reg[515:172]};
    assign b3_mux_out = (input_mux_sel == 1) ? {5'b0, in_b[1026:516]} : {172'b0, b3_reg[515:172]};
    
 
    // input registers
    reg input_enable;
    
    always @(posedge clk)
    begin
        if(resetn == 0)
        begin
            a1_reg <= 516'b0;
            a2_reg <= 516'b0;
            a3_reg <= 516'b0;
            b1_reg <= 516'b0;
            b2_reg <= 516'b0;
            b3_reg <= 516'b0;
        end
        else
            a1_reg <= a1_mux_out;
            b1_reg <= b1_mux_out;         
            a2_reg <= a2_mux_out;
            a3_reg <= a3_mux_out;
            b2_reg <= b2_mux_out;
            b3_reg <= b3_mux_out;            
    end

    // add/sub muxest bone a
    reg sub;
    always @(posedge clk)
    begin
        if(resetn == 0)
            sub <= 0;
        else
            sub <= subtract;
    end
    
    wire [171:0] add_sub_mux1;
    wire [171:0] add_sub_mux2;
    wire [171:0] add_sub_mux3;
    assign add_sub_mux1 = (sub == 1) ? ~b1_reg[171:0] : b1_reg[171:0];
    assign add_sub_mux2 = (sub == 1) ? ~b2_reg[171:0] : b2_reg[171:0];
    assign add_sub_mux3 = (sub == 1) ? ~b3_reg[171:0] : b3_reg[171:0];

    
        
        
    // adder
    wire carry_in1;
    wire carry_in2;
    wire carry_in3;
    wire [172:0] temp_result1;
    wire [172:0] temp_result2;
    wire [172:0] temp_result3;
    assign carry_in1 = carry_reg1;
    assign carry_in2 = carry_reg2;
    assign carry_in3 = carry_reg3;
    
    assign temp_result1 = a1_reg[171:0] + add_sub_mux1[171:0] + carry_in1;
    assign temp_result2 = a2_reg[171:0] + add_sub_mux2[171:0] + carry_in2;
    assign temp_result3 = a3_reg[171:0] + add_sub_mux3[171:0] + carry_in3;
    
    // carry register
    wire carry_mux1;
    wire carry_mux2;
    wire carry_mux3;
    reg carry_reg1;
    reg carry_reg2;
    reg carry_reg3;
    
    
    assign carry_mux1 = (start == 1) ? subtract : temp_result1[172];
    assign carry_mux2 = (start == 1) ? 1'b1 : temp_result2[172];
    assign carry_mux3 = (start == 1) ? 1'b0 : temp_result3[172];
    
        
    always @(posedge clk)
    begin
       if (resetn == 0) begin
            carry_reg1 <= 0;
            carry_reg2 <= 0;
            carry_reg3 <= 0;
            end
        else begin
            carry_reg2 <= carry_mux2;
            carry_reg3 <= carry_mux3;
            carry_reg1 <= carry_mux1;
            end
    end
    
    // Assign output
    reg carry_dec;
    wire carry_last;
    assign carry_last = carry_reg1;
    always @(posedge clk)
    begin
       if (resetn == 0) begin
            carry_dec <= 0;
            end
        else begin
            carry_dec <= carry_last;
            end
    end      
    assign result = (carry_dec == 1) ? {a2_reg[515:0], a1_reg[515:0]} : {a3_reg[515:0], a1_reg[515:0]};

    
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
    reg counter;
    always @(posedge clk)
    begin
        if (resetn == 0)
            counter <= 2'd0;
        else if (state == 2'd3)
            counter <= 0;
        else if (count_enable == 1)
            counter <= 1;
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
    else if (counter == 1)
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
