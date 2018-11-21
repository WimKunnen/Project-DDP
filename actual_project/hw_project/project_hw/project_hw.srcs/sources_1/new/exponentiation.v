`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: KU Leuven
// Engineer: Wim Kunnen
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module exponentiation(
    input  wire          clk,
    input  wire          resetn,
    input  wire          start,
    input  wire [1023:0] in_x,
    input  wire [1023:0] in_r,
    input  wire [1023:0] in_r2,
    input  wire [1023:0] in_m,
    input  wire [1023:0] in_e,
    input  wire [9:0] in_t,
    output wire [1023:0] result,
    output wire          done
    );


    // Intances of 1027 bit adder/subtracter module.
    reg mont_resetn;
    reg mont_start;
    reg mont_subtract;
    wire [1026:0] mont_input_a;
    wire [1026:0] mont_input_b;
    wire [1027:0] mont_result;
    wire [1023:0] mont_input_m;
    wire adder_done;
    assign result = a;
    
    montgomery mont(
         .clk      (clk           ),
         .resetn   (mont_resetn   ),
         .start    (mont_start    ),
         .in_a     (mont_input_a  ),
         .in_b     (mont_input_b  ),
         .in_m     (mont_input_m  ),
         .result   (mont_result   ),
         .done     (mont_done     )
       );

    assign mont_input_m = in_m;

    reg [1023:0] a;
    reg [9:0] t;
    reg [1023:0] x_tilde;
    reg [1023:0] e;
    reg [1023:0] input_a;
    reg [1023:0] input_b;
    reg [3:0] state, nextstate;

    assign mont_input_a = input_a;
    assign mont_input_b = input_b;

    always @(posedge clk)
    begin
      case (state)
        4'h0:
        begin
          a     <= in_r;
          e     <= in_e;
          t     <= in_t;
          input_a <= in_x;
          input_b <= in_r2;
        end
        4'h2:
          x_tilde <= mont_result;
        4'h3:
        begin
          input_a <= a;
          input_b <= a;
        end
        4'h4:
          a <= mont_result;
        4'h5:
          input_b <= x_tilde;
        4'h6:
          a <= mont_result;
        4'h7:
          input_b <= x_tilde;
        4'h9:
          input_b <= 1024'b1;
        4'ha:
          a <= mont_result;
        default: a <= a;
        endcase
    end

    // Reset
    always @(posedge clk)
    begin
        if(resetn==0)
            state <= 3'b0;
        else
            state <= nextstate;
    end

    // Done register
    reg done_reg;
    always @(posedge clk)
    begin
    if(resetn == 0)
        done_reg <= 0;
    else if (state == 4'hb)
        done_reg <= 1;
    else
        done_reg <= 0;
    end
    assign done = done_reg;

    // Add counter
    reg count_enable;
    reg [9:0] counter;
    always @(posedge clk)
    begin
        if (resetn == 0)
            counter <= 0;
        else if (state == 4'hb)
            counter <= 0;
        else if (count_enable == 1 && mont_done == 1)
            counter <= counter + 1;
    end

    // FSM
    always @(*)
      begin
        case (state)
        // Idle state
        4'h0:
          begin
            if (start)
             nextstate <= 4'b1;
            else
             nextstate <= 4'b0;
          end
        // X tilde state
        4'h1:
            nextstate <= 4'h2;
        4'h2:
          if (mont_done == 1)
            nextstate <= 4'h3;
          else
            nextstate <= state;
        // Loop state 1
        4'h3:
            nextstate <= 4'h4;
        4'h4:
          begin
            if (mont_done)
            begin
              if (e[0] == 1)
                nextstate <= 4'h5;
              else
                nextstate <= 4'h7;
            end
            else
              nextstate <= state;
          end
        // Loop state 2 e[t] = 1
        4'h5:
            nextstate <=4'h6;
        5'h6:
          begin
            if (mont_done)
            begin
              if (counter == t)
                nextstate <= 4'h9;
              else
                nextstate <= 4'h3;
            end
            else
              nextstate <= state;
          end
        // Loop state 2 e[t] = 0
        4'h7:
            nextstate <= 4'h8;
        4'h8:
          begin
            if (mont_done)
            begin
              if (counter == t)
                nextstate <= 4'h9;
              else
                nextstate <= 4'h3;
            end
            else
              nextstate <= state;
          end
        // Last mont state
        4'h9:
            nextstate <= 4'ha;
        4'ha:
          if (mont_done)
            nextstate <= 4'hb;
          else
            nextstate <= state;
        //Done state
        4'hb:
          nextstate <=3'h0;
        default: nextstate <= 4'b0;
        endcase
      end

    // Control path
    always @(*)
    begin
      case (state)
        // Idle state
        4'h0:
          begin
            mont_resetn  <= 1'b0;
            count_enable <= 1'b0;
            mont_start   <= 1'b0;
          end
        // X tilde state
        4'h1:
          begin
            mont_resetn  <= 1'b1;
            count_enable <= 1'b1;
            mont_start <= 1'b1;
          end
        4'h2:
            begin
            mont_resetn  <= 1'b1;
            count_enable <= 1'b0;
            mont_start <= 1'b0;
          end
        // Loop state 1
        4'h3:
          begin
            mont_resetn  <= 1'b1;
            count_enable <= 1'b1;
            mont_start <= 1'b1;
          end
         4'h4:
            begin
            mont_resetn  <= 1'b1;
            count_enable <= 1'b1;
            mont_start <= 1'b0;
          end
        // Loop state 2 e[t] = 1
        4'h5:
          begin
            mont_resetn  <= 1'b1;
            count_enable <= 1'b0;
            mont_start <= 1'b1;
          end
          4'h6:
           begin
            mont_resetn  <= 1'b1;
            count_enable <= 1'b0;
            mont_start <= 1'b0;
           end
        // Loop state 2 e[t] = 0
        4'h7:
          begin
            mont_resetn  <= 1'b1;
            count_enable <= 1'b0;
            mont_start <= 1'b1;
          end
          4'h8:
           begin
            mont_resetn  <= 1'b1;
            count_enable <= 1'b0;
            mont_start <= 1'b0;
           end
        // Last mont state
        4'h9:
          begin
            mont_resetn  <= 1'b1;
            count_enable <= 1'b0;
            mont_start <= 1'b1;
          end
          4'ha:
           begin
            mont_resetn  <= 1'b1;
            count_enable <= 1'b0;
            mont_start <= 1'b0;
           end
        // Done state
        4'hb:
          begin
            mont_resetn  <= 1'b1;
            count_enable <= 1'b0;
            mont_start <= 1'b0;
          end
        default :
          begin
            mont_resetn  <= 1'b0;
            count_enable <= 1'b0;
            mont_start <= 1'b0;
          end
      endcase
    end

endmodule
