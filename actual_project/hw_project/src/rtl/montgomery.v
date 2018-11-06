`timescale 1ns / 1ps

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
         .clk(clk),
         .resetn(adder_resetn),
         .start(adder_start),
         .subtract(adder_subtract),
         .in_a(adder_input_a),
         .in_b(adder_input_b),
         .result(adder_result),
         .done(adder_done)
         );


    // a register
    reg a_select;
    reg input_enable;
    reg [1023:0] a;
    wire [1023:0] a_mux;

    assign a_mux = (input_enable == 1) ? {in_a} : {2'b0, a[1023:2]};


    // b register
    reg b_select;
    reg [1023:0] b;
    reg [1025:0] b3;
    wire [1026:0] b_mux;

    assign b_mux = (a[1]==1 ? (a[0]==1 ? {1'b0,b3[1025:0]} : {2'b0,b[1023:0],1'b0}) : (a[0]==1 ? {3'b0,b[1023:0]} : {1027'b0}) );


    // m register
    reg m_select;
    reg [1023:0] m;
    reg [1025:0] m3;
    wire [1026:0] m_mux;

    assign m_mux = (m[1]==1 ? (c[1]==1 ? (c[0]==1 ? {1'b0,m3[1025:0]} : {2'b0,m[1023:0],1'b0}) : (c[0]==1 ? {3'b0,m[1023:0]} : {1027'b0}) ) :
                              (c[1]==1 ? (c[0]==1 ? {3'b0,m[1023:0]}  : {2'b0,m[1023:0],1'b0}) : (c[0]==1 ? {1'b0,m3[1025:0]}: {1027'b0}) ) ) ;


    // input adder
    reg zero_add;
    reg add_select;
    reg while_select;
    assign adder_input_a = zero_add==1 ? {c_out[1026:0]} : {1027'b0};
    assign adder_input_b = while_select==1 ? (add_select==1 ? {3'b0,b[1023:0]} : {3'b0,m[1023:0]}) : (add_select==1 ? b_mux : m_mux ) ;


    // c register
    reg c_select;
    reg shift_select;
    reg [1027:0] c;
    wire [1027:0] c_out;
    wire [1027:0] c_mux;

    assign c_out = c;
    assign c_mux = shift_select==1 ? {2'b0,adder_result[1027:2]} : {adder_result[1027:0]};



    // registers input select
    always @(posedge clk)
    begin
        if(resetn == 0)
        begin
            c  <= 1028'b0;
            a  <= 1024'b0;
            b  <= 1024'b0;
            b3 <= 1026'b0;
            m  <= 1024'b0;
            m3 <= 1026'b0;
        end
        else if (input_enable == 1) begin
            a <= a_mux;
            b <= in_b;
            m <= in_m;
        end
        if(a_select == 1)
            a <= a_mux;
        if(c_select == 1)
            c <= c_mux;
        if(b_select == 1)
            b3 <= c_out[1025:0];
        if(m_select == 1)
            m3 <= c_out[1025:0];
    end


    assign result = c_out[1023:0];


    // Done signal
    reg done_reg;
    always @(posedge clk)
    begin
    if(resetn == 0)
        done_reg <= 0;
    else if (state == 4'd15)
        done_reg <= 1;
    else
        done_reg <= 0;
    end
    assign done = done_reg;


    // Add cycle counter
    reg count_enable;
    reg [9:0] counter;
    always @(posedge clk)
    begin
        if (resetn == 0)
            counter <= 0;
        else if (state == 4'd15)
            counter <= 0;
        else if (count_enable == 1)
            counter <= counter + 1;
    end


    // FSM
    reg [3:0] state, nextstate;

    always @(posedge clk)
    begin
        if(resetn==0)
            state <= 4'd0;
        else
            state <= nextstate;
    end


    // define state signals
    always @(*)
    begin
      case(state)
            // Idle state
            4'd0: begin
                input_enable   <= 1'b1;
                a_select       <= 1'b0;
                b_select       <= 1'b0;
                c_select       <= 1'b0;
                m_select       <= 1'b0;
                add_select     <= 1'b0;
                while_select   <= 1'b0;
                zero_add       <= 1'b0;
                shift_select   <= 1'b0;
                count_enable   <= 1'b0;
                adder_resetn   <= 1'b1;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
            end
            // Start 3B add state
            4'd1: begin
                input_enable   <= 1'b0;
                a_select       <= 1'b0;
                b_select       <= 1'b0;
                c_select       <= 1'b0;
                m_select       <= 1'b0;
                add_select     <= 1'b1;
                while_select   <= 1'b1;
                zero_add       <= 1'b1;
                shift_select   <= 1'b0;
                count_enable   <= 1'b1;
                adder_resetn   <= 1'b0;
                adder_start    <= 1'b1;
                adder_subtract <= 1'b0;
            end
            // Done 3B add state
            4'd2: begin
                input_enable   <= 1'b0;
                a_select       <= 1'b0;
                b_select       <= 1'b1;
                c_select       <= 1'b1;
                m_select       <= 1'b0;
                add_select     <= 1'b0;
                while_select   <= 1'b0;
                zero_add       <= 1'b0;
                shift_select   <= 1'b0;
                count_enable   <= 1'b0;
                adder_resetn   <= 1'b0;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
            end
            // First 3M add state
            4'd3: begin
                input_enable   <= 1'b0;
                a_select       <= 1'b0;
                b_select       <= 1'b0;
                c_select       <= 1'b0;
                m_select       <= 1'b0;
                add_select     <= 1'b0;
                while_select   <= 1'b1;
                zero_add       <= 1'b0;
                shift_select   <= 1'b0;
                count_enable   <= 1'b1;
                adder_resetn   <= 1'b0;
                adder_start    <= 1'b1;
                adder_subtract <= 1'b0;
            end
            // Start 3M add state
            4'd4: begin
                input_enable   <= 1'b0;
                a_select       <= 1'b0;
                b_select       <= 1'b0;
                c_select       <= 1'b0;
                m_select       <= 1'b0;
                add_select     <= 1'b0;
                while_select   <= 1'b1;
                zero_add       <= 1'b1;
                shift_select   <= 1'b0;
                count_enable   <= 1'b1;
                adder_resetn   <= 1'b0;
                adder_start    <= 1'b1;
                adder_subtract <= 1'b0;
            end
            // Done 3M add state
            4'd5: begin
                input_enable   <= 1'b0;
                a_select       <= 1'b0;
                b_select       <= 1'b0;
                c_select       <= 1'b1;
                m_select       <= 1'b1;
                add_select     <= 1'b0;
                while_select   <= 1'b0;
                zero_add       <= 1'b0;
                shift_select   <= 1'b0;
                count_enable   <= 1'b0;
                adder_resetn   <= 1'b0;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
            end
            // First B-mux state
            4'd6: begin
                input_enable   <= 1'b0;
                a_select       <= 1'b1;
                b_select       <= 1'b0;
                c_select       <= 1'b0;
                m_select       <= 1'b0;
                add_select     <= 1'b1;
                while_select   <= 1'b0;
                zero_add       <= 1'b0;
                shift_select   <= 1'b0;
                count_enable   <= 1'b1;
                adder_resetn   <= 1'b0;
                adder_start    <= 1'b1;
                adder_subtract <= 1'b0;
            end
            // Start B-mux state
            4'd7: begin
                input_enable   <= 1'b0;
                a_select       <= 1'b1;
                b_select       <= 1'b0;
                c_select       <= 1'b0;
                m_select       <= 1'b0;
                add_select     <= 1'b1;
                while_select   <= 1'b0;
                zero_add       <= 1'b1;
                shift_select   <= 1'b0;
                count_enable   <= 1'b1;
                adder_resetn   <= 1'b0;
                adder_start    <= 1'b1;
                adder_subtract <= 1'b0;
            end
            // Done B-mux state
            4'd8: begin
                input_enable   <= 1'b0;
                a_select       <= 1'b0;
                b_select       <= 1'b0;
                c_select       <= 1'b1;
                m_select       <= 1'b0;
                add_select     <= 1'b0;
                while_select   <= 1'b0;
                zero_add       <= 1'b1;
                shift_select   <= 1'b0;
                count_enable   <= 1'b0;
                adder_resetn   <= 1'b0;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
            end
            // Start M-mux state
            4'd9: begin
                input_enable   <= 1'b0;
                a_select       <= 1'b0;
                b_select       <= 1'b0;
                c_select       <= 1'b0;
                m_select       <= 1'b0;
                add_select     <= 1'b0;
                while_select   <= 1'b0;
                zero_add       <= 1'b1;
                shift_select   <= 1'b0;
                count_enable   <= 1'b0;
                adder_resetn   <= 1'b0;
                adder_start    <= 1'b1;
                adder_subtract <= 1'b0;
            end
            // Done M-mux state
            4'd10: begin
                input_enable   <= 1'b0;
                a_select       <= 1'b0;
                b_select       <= 1'b0;
                c_select       <= 1'b1;
                m_select       <= 1'b0;
                add_select     <= 1'b0;
                while_select   <= 1'b0;
                zero_add       <= 1'b1;
                shift_select   <= 1'b1;
                count_enable   <= 1'b0;
                adder_resetn   <= 1'b0;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
            end
            // Start M-subtract state
            4'd11: begin
                input_enable   <= 1'b0;
                a_select       <= 1'b0;
                b_select       <= 1'b0;
                c_select       <= 1'b0;
                m_select       <= 1'b0;
                add_select     <= 1'b0;
                while_select   <= 1'b1;
                zero_add       <= 1'b1;
                shift_select   <= 1'b0;
                count_enable   <= 1'b0;
                adder_resetn   <= 1'b0;
                adder_start    <= 1'b1;
                adder_subtract <= 1'b1;
            end
            // Done M-subtract state
            4'd12: begin
                input_enable   <= 1'b0;
                a_select       <= 1'b0;
                b_select       <= 1'b0;
                c_select       <= 1'b1;
                m_select       <= 1'b0;
                add_select     <= 1'b0;
                while_select   <= 1'b1;
                zero_add       <= 1'b1;
                shift_select   <= 1'b0;
                count_enable   <= 1'b0;
                adder_resetn   <= 1'b0;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
            end
            // Start add M state
            4'd13: begin
                input_enable   <= 1'b0;
                a_select       <= 1'b0;
                b_select       <= 1'b0;
                c_select       <= 1'b0;
                m_select       <= 1'b0;
                add_select     <= 1'b0;
                while_select   <= 1'b1;
                zero_add       <= 1'b1;
                shift_select   <= 1'b0;
                count_enable   <= 1'b0;
                adder_resetn   <= 1'b0;
                adder_start    <= 1'b1;
                adder_subtract <= 1'b0;
            end
            // Done add M state
            4'd14: begin
                input_enable   <= 1'b0;
                a_select       <= 1'b0;
                b_select       <= 1'b0;
                c_select       <= 1'b1;
                m_select       <= 1'b0;
                add_select     <= 1'b0;
                while_select   <= 1'b1;
                zero_add       <= 1'b1;
                shift_select   <= 1'b0;
                count_enable   <= 1'b0;
                adder_resetn   <= 1'b0;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
            end
            // Done state
            4'd15: begin
                input_enable   <= 1'b0;
                a_select       <= 1'b0;
                b_select       <= 1'b0;
                c_select       <= 1'b0;
                m_select       <= 1'b0;
                add_select     <= 1'b0;
                while_select   <= 1'b0;
                zero_add       <= 1'b0;
                shift_select   <= 1'b0;
                count_enable   <= 1'b0;
                adder_resetn   <= 1'b0;
                adder_start    <= 1'b0;
                adder_subtract <= 1'b0;
            end
        endcase
     end

     // Define state sequence
     always @(*)
        begin
            case(state)
            // Idle state
                4'd0: begin
                    if(start)
                        nextstate <= 4'd1;
                    else
                        nextstate <= 4'd0;
                end
            // Start 3B add state
                4'd1: begin
                        nextstate <= 4'd2;
                end
            // Done 3B add state
                4'd2: begin
                    if (adder_done == 1)
                        if (counter == 3)
                            nextstate <= 4'd3;
                        else
                            nextstate <= 4'd1;
                    else
                        nextstate <= state;
                end
            // First 3M add state
                4'd3: begin
                        nextstate <= 4'd5;
                end
            // Start 3M add state
                4'd4: begin
                        nextstate <= 4'd5;
                end
            // Start 3M add state
                4'd5: begin
                    if (adder_done == 1)
                        if (counter == 6)
                            nextstate <= 4'd6;
                        else
                            nextstate <= 4'd4;
                    else
                        nextstate <= state;
                end
            // First B-mux add add state
                4'd6: begin
                        nextstate <= 4'd8;
                end
            // Start B-mux state
                4'd7: begin
                        nextstate <= 4'd8;
                end
            // Done B-mux state
                4'd8: begin
                    if (adder_done == 1)
                        nextstate <= 4'd9;
                    else
                        nextstate <= state;
                end
            // Start M-mux state
                4'd9: begin
                        nextstate <= 4'd10;
                end
            // Done M-mux state
                4'd10: begin
                    if (adder_done == 1)
                        if (counter == 518)
                            nextstate <= 4'd11;
                        else
                            nextstate <= 4'd7;
                    else
                        nextstate <= state;
                end
            // Start M-subtract state
                4'd11: begin
                        nextstate <= 4'd12;
                end
            // Check Done M-subtract state
                4'd12: begin
                    if (adder_done == 1)
                        if (c[1027:1024] < 0)
                            nextstate <= 4'd13;
                        else
                            nextstate <= 4'd11;
                    else
                        nextstate = state;
                end

            // Start add M state
                4'd13: begin
                        nextstate <= 4'd14;
                end
            // Done add M state
                4'd14: begin
                    if (adder_done == 1)
                        nextstate <= 4'd15;
                    else
                        nextstate <= state;
                end
            // Done state
                4'd15: begin
                        nextstate <= 4'd0;
                end

                default: nextstate <= 4'd0;
            endcase
        end
/*        // ideetje om alle done states te combineren, of alleszins meer
          // in principe vooral wachten tot optellig klaar is en dan c-Mux inladen
          // kijken naar hoe signalen verschillen tussen de states
          // Done_wait state
            4'd1: begin
            if (adder_done == 1)begin
                if (state == 4'd3)
                    nextstate <= 4'd2;
                if (state == 4'd5)
                    nextstate <= 4'd4;
                if (state == 4'd7)
                    nextstate <= 4'd6;
                if (state == 4'd8)
                    nextstate <= 4'd7;
                end
            else
                nextstate <= state;
            end   */

endmodule
