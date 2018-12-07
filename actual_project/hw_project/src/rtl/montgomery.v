`timescale 1ns / 1ps


// Synthesis : Flow PerfOptimized high
// Implemetation : Performance ExtraTimingOpt
// WNS 0.0
// LUT  = .84%
// FF  = .91%
module montgomery(
    input  wire          clk,
    input  wire          resetn,
    input  wire          start,
    input  wire [1023:0] in_a,
    input  wire [1023:0] in_b,
    input  wire [1023:0] in_m,
    output wire [1023:0] result,
    output wire          done
     );


    // Intances of 1027 bit adder/subtracter module.
    reg adder_resetn;
    reg adder_start;
    reg adder_subtract;
    wire [1026:0] adder_input_a;
    wire [1026:0] adder_input_b;
    wire [1027:0] adder_result;
    wire adder_done;

    mpadder adder(
         .clk      (clk            ),
         .resetn   (adder_resetn   ),
         .start    (adder_start    ),
         .subtract (adder_subtract ),
         .in_a     (adder_input_a  ),
         .in_b     (adder_input_b  ),
         .result   (adder_result   ),
         .done     (adder_done     )
         );


    // a register
    reg a_select;
    reg [1023:0] a;
    wire [1023:0] a_mux;

    assign a_mux = start==1 ? {in_a} : {2'b0, a[1023:2]};

    // b/m registers
    reg [1027:0] b3m3;
    reg [1027:0] b3m2;
    reg [1027:0] b3m1;
    reg [1027:0] b3m0;
    reg [1027:0] b2m3;
    reg [1027:0] b2m1;
    reg [1027:0] b2m0;
    reg [1027:0] b1m3;
    reg [1027:0] b1m2;
    reg [1027:0] b1m1;
    reg [1027:0] b0m3;
    
    reg [1023:0] res_keep;

    wire [1:0] b_needed;
    wire [1:0] b_add;
    wire [1:0] c_new;
    wire [1:0] m_needed;


    assign b_needed = (a[1]==1 ? (a[0]==1 ? {2'b11} : {2'b10}) :
                                 (a[0]==1 ? {2'b01} : {2'b00}) );
    assign b_add = (a[1]==1 ? (a[0]==1 ? {b3m0[1:0]} : {in_b[0],1'b0}) :
                                 (a[0]==1 ? {in_b[1:0]} : {2'b0}) );
    assign c_new = c_mux[1:0] + b_add[1:0];
    assign m_needed = (c_new[0]==1 ? (in_m[1]==c_new[1] ? {2'b11} : {2'b01}) :
                                     (c_new[1]==1       ? {2'b10} : {2'b00}) ) ;

    // input adder
    reg zero_add;
    reg add_select;
    assign adder_input_a = (zero_add==1 ? {c_mux[1026:0]} : {1027'b0});
    assign adder_input_b = prep_stage == 1 ? (add_select == 1 ? {3'b0,in_b[1023:0]} : {3'b0,in_m[1023:0]}) :
         (b_needed[1]==1 ? (b_needed[0]==1 ? (m_needed[1]==1 ? (m_needed[0]==1 ? b3m3[1026:0] : b3m2[1026:0]) :
                                                               (m_needed[0]==1 ? b3m1[1026:0] : b3m0[1026:0]) ) :
                                             (m_needed[1]==1 ? (m_needed[0]==1 ? b2m3[1026:0] : {b1m1[1025:0],1'b0}) :
                                                               (m_needed[0]==1 ? b2m1[1026:0] : b2m0[1026:0]) ) ) :
                           (b_needed[0]==1 ? (m_needed[1]==1 ? (m_needed[0]==1 ? b1m3[1026:0] : b1m2[1026:0]) :
                                                               (m_needed[0]==1 ? b1m1[1026:0] : {3'b0,in_b[1023:0]}) ) :
                                             (m_needed[1]==1 ? (m_needed[0]==1 ? b0m3[1026:0] : {2'b0,in_m[1023:0],1'b0}) :
                                                               (m_needed[0]==1 ? {3'b0,in_m[1023:0]} : 1027'b0) ) ) ) ;



    // c register
    reg prep_stage;
    wire [1027:0] c_mux;

    assign c_mux = prep_stage==1 ? {adder_result[1027:0]} : {2'b0,adder_result[1027:2]};

    // registers input select
    always @(posedge clk)
    begin
        if(resetn == 0)
        begin
            a  <= 1024'b0;
            b3m3 <= 1027'b0;
            b3m2 <= 1027'b0;
            b3m1 <= 1027'b0;
            b3m0 <= 1027'b0;
            b2m3 <= 1027'b0;
            b2m1 <= 1027'b0;
            b2m0 <= 1027'b0;
            b1m3 <= 1027'b0;
            b1m2 <= 1027'b0;
            b1m1 <= 1027'b0;
            b0m3 <= 1027'b0;            
        end
        else begin
        if(start == 1) 
            b2m0 <= {2'b0,in_b[1023:0],1'b0};
        if(a_select == 1)
            a <= a_mux;
        if(counter == 3)
            b3m0 <= c_mux[1026:0];
        if(counter == 4)
            b3m1 <= c_mux[1026:0];
        if(counter == 5)
            b3m2 <= c_mux[1026:0];
        if(counter == 6)
            b3m3 <= c_mux[1026:0];
        if(counter == 7)
            b2m3 <= c_mux[1026:0];
        if(counter == 8)
            b1m3 <= c_mux[1026:0];
        if(counter == 9)
            b0m3 <= c_mux[1026:0];
        if(counter == 11)
            b1m2 <= c_mux[1026:0];
        if(counter == 12)
            b1m1 <= c_mux[1026:0];
        if(counter == 13)
            b2m1 <= c_mux[1026:0];
        if (state == 6'd26)
            res_keep <= c_mux[1023:0];
        end
    end


    assign result = res_keep[1023:0];


    // Done signal
    reg done_reg;
    always @(posedge clk)
    begin
    if(resetn == 0)
        done_reg <= 0;
    else if (state == 6'd27)
        done_reg <= 1;
    else
        done_reg <= 0;
    end
    assign done = done_reg;


    // Add cycle counter
    reg [9:0] counter;
    always @(posedge clk)
    begin
        if (resetn == 0)
            counter <= 0;
        else if (state == 6'd27)
            counter <= 0;
        else if (adder_start == 1)
            counter <= counter + 1;
    end

    // FSM
    reg [5:0] state, nextstate;

    always @(posedge clk)
    begin
        if(resetn==0)
            state <= 6'd0;
        else
            state <= nextstate;
    end


    // define state signals
    always @(*)
    begin
      case(state)
            // Idle state
            6'd0: begin
                a_select       <= 1'b1;
                add_select     <= 1'b0;
                prep_stage     <= 1'b1;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
                zero_add       <= 1'b0;
                adder_resetn   <= 1'b0;
            end

            // First 3B add state
            6'd1: begin
                a_select       <= 1'b0;
                add_select     <= 1'b1;
                prep_stage     <= 1'b1;
                adder_start    <= 1'b1;
                adder_subtract <= 1'b0;
                zero_add       <= 1'b0;
                adder_resetn   <= 1'b1;
            end
            // Wait1 3B add state
            6'd2: begin
                a_select       <= 1'b0;
                add_select     <= 1'b1;
                prep_stage     <= 1'b1;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
                zero_add       <= 1'b1;
                adder_resetn   <= 1'b1;
            end
            // Wait2 3B add state
            6'd3: begin
                a_select       <= 1'b0;
                add_select     <= 1'b1;
                prep_stage     <= 1'b1;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
                zero_add       <= 1'b1;
                adder_resetn   <= 1'b1;
            end
            // Done 3B add state
             6'd4: begin
                 a_select       <= 1'b0;
                 if (counter == 3) begin
                     add_select     <= 1'b0;
                     end
                 else begin
                     add_select     <= 1'b1;
                     end
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b1;
                 adder_subtract <= 1'b0;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end

            // Wait1 3M add state
            6'd5: begin
                a_select       <= 1'b0;
                add_select     <= 1'b0;
                prep_stage     <= 1'b1;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
                zero_add       <= 1'b1;
                adder_resetn   <= 1'b1;
            end
            // Wait2 3M add state
            6'd6: begin
                a_select       <= 1'b0;
                add_select     <= 1'b0;
                prep_stage     <= 1'b1;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
                zero_add       <= 1'b1;
                adder_resetn   <= 1'b1;
            end
            // Done 3M add state
             6'd7: begin
                 a_select       <= 1'b0;
                 if (counter == 6) begin
                     add_select     <= 1'b1;
                     adder_subtract    <= 1'b1;
                     end
                 else begin
                     add_select     <= 1'b0;
                     adder_subtract    <= 1'b0;
                     end
                 prep_stage     <= 1'b1;
                 adder_start <= 1'b1;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end



             // Wait1 3B sub state
             6'd8: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b1;
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b0;
                 adder_subtract <= 1'b1;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
             // Wait2 3B sub state
             6'd9: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b1;
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b0;
                 adder_subtract <= 1'b1;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
             // Done 3B sub state
             6'd10: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b1;
                 if (counter == 9) begin
                     adder_subtract <= 1'b0;
                     end
                 else begin
                     adder_subtract <= 1'b1;
                     end
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b1;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end


             // Wait1 1B add state
             6'd41: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b1;
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b0;
                 adder_subtract <= 1'b0;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
             // Wait2 1B add state
             6'd42: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b1;
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b0;
                 adder_subtract <= 1'b0;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
             // Done 1B add state
             6'd43: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b0;
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b1;
                 adder_subtract <= 1'b1;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
             
             // Wait1 2M sub state
             6'd11: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b0;
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b0;
                 adder_subtract <= 1'b1;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
             // Wait2 2M sub state
             6'd12: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b0;
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b0;
                 adder_subtract <= 1'b1;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
             // Done 2M sub state
             6'd13: begin
                 a_select       <= 1'b0;
                 if (counter == 12) begin
                     add_select     <= 1'b1;
                     adder_subtract <= 1'b0;
                     end
                 else begin
                     add_select     <= 1'b0;
                     adder_subtract <= 1'b1;
                     end
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b1;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end


             // Wait1 1B add state
             6'd14: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b1;
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b0;
                 adder_subtract <= 1'b0;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
             // Wait2 1B add state
             6'd15: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b1;
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b0;
                 adder_subtract <= 1'b0;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
             // Done 1B add state
             6'd16: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b1;
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b1;
                 adder_subtract <= 1'b1;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
//                 a_select       <= 1'b0;
//                 if (counter == 15) begin
//                     add_select     <= 1'b1;
//                     end
//                 else begin
//                     add_select     <= 1'b0;
//                     end
//                 adder_subtract <= 1'b1;    
//                 prep_stage     <= 1'b1;
//                 adder_start    <= 1'b1;
//                 zero_add       <= 1'b1;
//                 adder_resetn   <= 1'b1;
//             end            
             
             // Wait1 2B sub state
             6'd31: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b1;
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b0;
                 adder_subtract <= 1'b1;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
             // Wait2 2B sub state
             6'd32: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b1;
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b0;
                 adder_subtract <= 1'b1;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
             // Done 2B sub state
             6'd33: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b1;
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b1;
                 adder_subtract <= 1'b1;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
             // Wait1 B sub state
             6'd34: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b1;
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b0;
                 adder_subtract <= 1'b1;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
             // Wait2 2B sub state
             6'd35: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b1;
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b0;
                 adder_subtract <= 1'b1;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
             // Done 2B sub state
             6'd36: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b0;
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b1;
                 adder_subtract <= 1'b1;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
             // Wait1 1M sub state
             6'd37: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b0;
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b0;
                 adder_subtract <= 1'b1;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
             // Wait2 1M sub state
             6'd38: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b0;
                 prep_stage     <= 1'b1;
                 adder_start    <= 1'b0;
                 adder_subtract <= 1'b1;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
             // Done 1M sub state
             6'd39: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b0;
                 prep_stage     <= 1'b0;
                 adder_start    <= 1'b0;
                 adder_subtract <= 1'b0;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end
             
             // LAST Pre-stage state
             6'd40: begin
                 a_select       <= 1'b0;
                 add_select     <= 1'b0;
                 prep_stage     <= 1'b0;
                 adder_start    <= 1'b1;
                 adder_subtract <= 1'b0;
                 zero_add       <= 1'b1;
                 adder_resetn   <= 1'b1;
             end             

            // Wait1 algoritmitic state
            6'd18: begin
                a_select       <= 1'b1;
                add_select     <= 1'b0;
                prep_stage     <= 1'b0;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
                zero_add       <= 1'b1;
                adder_resetn   <= 1'b1;
            end
            // Wait2 algoritmitic state
            6'd19: begin
                a_select       <= 1'b0;
                add_select     <= 1'b0;
                prep_stage     <= 1'b0;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
                zero_add       <= 1'b1;
                adder_resetn   <= 1'b1;
            end
            // Done algoritmitic state
            6'd20: begin
                a_select       <= 1'b0;
                add_select     <= 1'b0;
                
                if (counter == 529) begin
                    adder_subtract <= 1'b1;
                    prep_stage     <= 1'b1;
                end
                else begin
                    adder_subtract <= 1'b0;
                    prep_stage     <= 1'b0;
                end
                adder_start    <= 1'b1;
                zero_add       <= 1'b1;
                adder_resetn   <= 1'b1;
            end


            // Wait1 M-subtract state
            6'd21: begin
                a_select       <= 1'b0;
                add_select     <= 1'b0;
                prep_stage     <= 1'b1;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b1;
                zero_add       <= 1'b1;
                adder_resetn   <= 1'b1;
            end
            // Wait2 M-subtract state
            6'd22: begin
                a_select       <= 1'b0;
                add_select     <= 1'b0;
                prep_stage     <= 1'b1;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b1;
                zero_add       <= 1'b1;
                adder_resetn   <= 1'b1;
            end
            // Done M-subtract state
            6'd23: begin
                a_select       <= 1'b0;
                add_select     <= 1'b0;
                prep_stage     <= 1'b1;
                if (c_mux[1027] == 1) begin
                    adder_subtract <= 1'b0;
                end
                else begin
                    adder_subtract <= 1'b1;
                end
                adder_start    <= 1'b1;
                zero_add       <= 1'b1;
                adder_resetn   <= 1'b1;
            end


            // Wait1 add M state
            6'd24: begin
                a_select       <= 1'b0;
                add_select     <= 1'b0;
                prep_stage     <= 1'b1;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
                zero_add       <= 1'b1;
                adder_resetn   <= 1'b1;
            end
            // Wait2 add M state
            6'd25: begin
                a_select       <= 1'b0;
                add_select     <= 1'b0;
                prep_stage     <= 1'b1;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
                zero_add       <= 1'b1;
                adder_resetn   <= 1'b1;
            end
            // Done add M state
            6'd26: begin
                a_select       <= 1'b0;
                add_select     <= 1'b0;
                prep_stage     <= 1'b1;
                if (counter[0] == 1) begin
                    adder_start    <= 1'b0;
                    end
                else begin
                    adder_start    <= 1'b1;
                    end
                adder_subtract <= 1'b0;
                zero_add       <= 1'b1;
                adder_resetn   <= 1'b1;
            end


            // Done all state
            6'd27: begin
                a_select       <= 1'b0;
                add_select     <= 1'b0;
                prep_stage     <= 1'b1;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
                zero_add       <= 1'b0;
                adder_resetn   <= 1'b1;
            end


            // Wait1 Dummy state
            6'd28: begin
                a_select       <= 1'b0;
                add_select     <= 1'b0;
                prep_stage     <= 1'b1;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
                zero_add       <= 1'b1;
                adder_resetn   <= 1'b1;
            end
            // Wait2 Dummy state
            6'd29: begin
                a_select       <= 1'b0;
                add_select     <= 1'b0;
                prep_stage     <= 1'b1;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
                zero_add       <= 1'b1;
                adder_resetn   <= 1'b1;
            end
            // Done Dummy state
            6'd30: begin
                a_select       <= 1'b0;
                add_select     <= 1'b0;
                prep_stage     <= 1'b1;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
                zero_add       <= 1'b1;
                adder_resetn   <= 1'b1;
            end

            // Default state
            default: begin
                a_select       <= 1'b1;
                add_select     <= 1'b0;
                prep_stage     <= 1'b1;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
                zero_add       <= 1'b0;
                adder_resetn   <= 1'b0;
            end
        endcase
     end

     // Define state sequence
     always @(*)
        begin
            case(state)
            // Idle state
                6'd0: begin
                    if(start)
                        nextstate <= 6'd1;
                    else
                        nextstate <= 6'd0;
                end
            // First 3B add state
                6'd1: begin
                        nextstate <= 6'd2;
                end
            // Wait1 3B add state
                6'd2: begin
                        nextstate <= 6'd3;
                end
            // Wait2 3B add state
                6'd3: begin
                        nextstate <= 6'd4;
                end
            // Done 3B add state
                6'd4: begin
                    if(counter == 3)
                        nextstate <= 6'd5;
                    else
                        nextstate <= 6'd2;
                end

            // Wait1 3M add state
                6'd5: begin
                        nextstate <= 6'd6;
                end
            // Wait2 3M add state
                6'd6: begin
                        nextstate <= 6'd7;
                end
            // Done 3M add state
                6'd7: begin
                    if(counter == 6)
                        nextstate <= 6'd8;
                    else
                        nextstate <= 6'd5;
                end

             // Wait1 S2B add state
                6'd8: begin
                        nextstate <= 6'd9;
                end
            // Wait2 S2B add state
                6'd9: begin
                        nextstate <= 6'd10;
                end
            // Done S2B add state
                6'd10: begin
                    if(counter == 9)
                        nextstate <= 6'd41;
                    else
                        nextstate <= 6'd8;
                end

            // Wait1 B add state
                6'd41: begin
                        nextstate <= 6'd42;
                end
            // Wait2 B add state
                6'd42: begin
                        nextstate <= 6'd43;
                end                
            // Done B add state
                6'd43: begin
                        nextstate <= 6'd11;
                end
                

            // Wait1 S2M add state
                6'd11: begin
                        nextstate <= 6'd12;
                end
            // Wait2 S2M add state
                6'd12: begin
                        nextstate <= 6'd13;
                end
            // Done S2M add state
                6'd13: begin
                    if(counter == 12)
                        nextstate <= 6'd14;
                    else
                        nextstate <= 6'd11;
                end

            // Wait1 B add state
                6'd14: begin
                        nextstate <= 6'd15;
                end
            // Wait2 B add state
                6'd15: begin
                        nextstate <= 6'd16;
                end                
            // Done B add state
                6'd16: begin
                        nextstate <= 6'd31;
                end


            // Wait1 B add state
                6'd31: begin
                        nextstate <= 6'd32;
                end
            // Wait2 B add state
                6'd32: begin
                        nextstate <= 6'd33;
                end                
            // Done B add state
                6'd33: begin
                        nextstate <= 6'd34;
                end
            // Wait1 B add state
                6'd34: begin
                        nextstate <= 6'd35;
                end
            // Wait2 B add state
                6'd35: begin
                        nextstate <= 6'd36;
                end                
            // Done B add state
                6'd36: begin
                        nextstate <= 6'd37;
                end
            // Wait1 B add state
                6'd37: begin
                        nextstate <= 6'd38;
                end
            // Wait2 B add state
                6'd38: begin
                        nextstate <= 6'd39;
                end                
            // Done B add state
                6'd39: begin
                        nextstate <= 6'd40;
                end
            // Done B add state
                6'd40: begin
                        nextstate <= 6'd18;
                end
               
                
                
            // Wait1 algoritmitic state
                6'd18: begin
                        nextstate <= 6'd19;
                end
            // Wait2 algoritmitic state
                6'd19: begin
                        nextstate <= 6'd20;
                end
            // Done algoritmitic state
                6'd20: begin
                    if (counter == 529)
                        nextstate <= 6'd21;
                    else
                        nextstate <= 6'd18;
                end


            // Wait1 M-substract state
                6'd21: begin
                        nextstate <= 6'd22;
                end
            // Wait2 M-substract state
                6'd22: begin
                        nextstate <= 6'd23;
                end
            // Done M-subtract state
                6'd23: begin
                        if (c_mux[1027] == 1)
                            nextstate <= 6'd24;
                        else
                            nextstate <= 6'd21;
                end
            // Wait1 M-substract state
                6'd24: begin
                       nextstate <= 6'd25;
                end
            // Wait2 M-substract state
                6'd25: begin
                       nextstate <= 6'd26;
                end
            // Done add M state
                6'd26: begin
                        if (counter[0] == 1)
                            nextstate <= 6'd27;
                        else
                            nextstate <= 6'd28;
                end

            // Done state
                6'd27: begin
                        nextstate <= 6'd0;
                end

            // Wait1 Dummy state
                6'd28: begin
                        nextstate <= 6'd29;
                end
            // Wait2 Dummy state
                6'd29: begin
                        nextstate <= 6'd30;
                end
            // Done Dummy state
                6'd30: begin
                        nextstate <= 6'd27;
                end

            // Default state
                default: nextstate <= 6'd0;
            endcase
        end

endmodule