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

    wire [127:0] adder_result;
    wire [129:0] pre_adder_result[1:0];
    wire [129:0] sec_pre_adder_result[1:0];
    wire [129:0] thr_pre_adder_result[1:0];
    
    // in_a mux
    reg input_mux_sel;
    reg [1027:0] a;
    
    wire [129:0] predicted_mux;
    wire [129:0] sec_predicted_mux;
    wire [129:0] thr_predicted_mux;
    wire [1027:0] a_mux;
    assign predicted_mux = adder_result[127] == 1 ? pre_adder_result[1] : pre_adder_result[0];
    assign sec_predicted_mux = (adder_result[127] == 1 ? (pre_adder_result[1][129]==1 ? sec_pre_adder_result[1] : sec_pre_adder_result[0]) :
                                                         (pre_adder_result[0][129]==1 ? sec_pre_adder_result[1] : sec_pre_adder_result[0]) );
    assign thr_predicted_mux = (adder_result[127] == 1 ? (pre_adder_result[1][129]==1 ? (sec_pre_adder_result[1][129]==1 ? thr_pre_adder_result[1] : thr_pre_adder_result[0]) : (sec_pre_adder_result[0][129]==1 ? thr_pre_adder_result[1] : thr_pre_adder_result[0]) ):
                                                         (pre_adder_result[0][129]==1 ? (sec_pre_adder_result[1][129]==1 ? thr_pre_adder_result[1] : thr_pre_adder_result[0]) : (sec_pre_adder_result[0][129]==1 ? thr_pre_adder_result[1] : thr_pre_adder_result[0]) ) );  

    assign a_mux = (input_mux_sel == 1) ? {1'b0,in_a} : {thr_predicted_mux[128:0],sec_predicted_mux[128:0],predicted_mux[128:0],adder_result[126:0],a[1027:514]}; 
    
    // in_b mux
    reg [1027:0] b;
    wire [1027:0] b_mux;   

    assign b_mux = (input_mux_sel == 1) ? ( subtract == 1 ? {1'b1,~in_b} : {1'b0,in_b}) : {514'b0, b[1027:514]};
    
    // input registers
    reg input_enable;
    	
    always @(posedge clk)
    begin
        if(resetn == 0)
        begin
            a <= 1028'b0;
            b <= 1028'b0;
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
    assign adder_result = a[126:0] + b[126:0] + carry_in;
    assign pre_adder_result[0] = a[255:127] + b[255:127];
    assign pre_adder_result[1] = a[255:127] + b[255:127] + 1;
    assign sec_pre_adder_result[0] = a[384:256] + b[384:256];
    assign sec_pre_adder_result[1] = a[384:256] + b[384:256] + 1;   
    assign thr_pre_adder_result[0] = a[513:385] + b[513:385];
    assign thr_pre_adder_result[1] = a[513:385] + b[513:385] + 1;
     
    // carry register
    assign carry_mux = (start==1) ? subtract : (adder_result[127]==1 ? (pre_adder_result[1][129]==1 ? (sec_pre_adder_result[1][129]==1 ? thr_pre_adder_result[1][129] : thr_pre_adder_result[0][129]) : (sec_pre_adder_result[0][129]==1 ? thr_pre_adder_result[1][129] : thr_pre_adder_result[0][129]) ) :
                                                                       (pre_adder_result[0][129]==1 ? (sec_pre_adder_result[1][129]==1 ? thr_pre_adder_result[1][129] : thr_pre_adder_result[0][129]) : (sec_pre_adder_result[0][129]==1 ? thr_pre_adder_result[1][129] : thr_pre_adder_result[0][129]) ) );
   
   
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
                input_enable <= start;
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
                    if (counter == 1)
                        nextstate <= 2'd3;
                    else
                        nextstate <= state;
                end
                2'd2: begin
                    if (counter == 1)
                        nextstate <= 2'd3;
                    else
                        nextstate <= state;
                end
                2'd3: begin
                    if (start == 1)
                        nextstate <= 2'b1;
                    else
                        nextstate <= 2'd0;
                    end
                default: nextstate <= 2'd0;
            endcase
        end
endmodule