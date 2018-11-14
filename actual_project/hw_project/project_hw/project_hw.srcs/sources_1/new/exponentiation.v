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
    input  wire [1023:0] in_t,
    output wire [1023:0] result,
    output wire          done
    );


    // Intances of 1027 bit adder/subtracter module.
    reg mont_resetn;
    reg mont_start;
    reg mont_subtract;
    wire [1026:0] mont_input_a;
    wire [1026:0] mont_input_b;
    wire [1027:0] montesult;
    wire adder_done;

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

    reg [1023:0] r2;
    reg [1023:0] a;
    reg [1023:0] reg_x;
    reg [1023:0] x_tilde;
    reg [1023:0] e;
    reg [1023:0] m;
    reg [9:0] size;
    reg [9:0] counter;
    reg [2:0] state, nextstate;
    reg step;
    reg loop;
    reg end_loop;

    assign mont_input_a = (state == 3'b1) ? reg_x  : {a};
    assign mont_input_b = (loop == 0 )    ? ( (end_loop ==0) ? in_r2 : {1024'b1} ) : ( (state == 3'b4) ? {a} : {x_tilde} );

    always @(posedge clk)
    begin
      case (state)
        3'b0:
        begin
          r2    <= in_r2;
          a     <= in_r;
          e     <= in_e;
          t     <= in_t;
          m     <= in_m;
          reg_x <= in_x;
        end
        3'b1:
          x_tilde <= mont_result;
        3'b2:
          a <= mont_result;
        3'b3:
          a <= mont_result;
        3'b4:
          a <= a;
        3'b5:
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
    else if (state == 3'b6)
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
        else if (state == 3'b5)
            counter <= 0;
        else if (count_enable == 1 && mont_done == 1)
            counter <= counter + 1;
    end

    // FSM
    always @(*)
      begin
        case (state)
        // Idle state
        3'b0:
          begin
            if (start)
             nextstate <= 3'b1;
            else
             nextstate <= 3'b0;
          end
        // X tilde state
        3'b1:
          if (mont_done == 1)
            nextstate <= 3'b2;
        // Loop state 1
        3'b2:
          begin
            if (mont_done)
            begin
              if (e[0] == 1)
                nextstate <= 3'b3;
              else
                nextstate <= 3'b4;
            end
            else
              nextstate <= state;
          end
        // Loop state 2 e[t] = 1
        3'b3:
          begin
            if (mont_done)
            begin
              if (counter == size)
                nextstate <= 3'b5;
              else
                nextstate <= 3'b2;
            end
            else
              nextstate <= state;
          end
        // Loop state 2 e[t] = 0
        3'b4:
          begin
            if (mont_done)
            begin
              if (counter == t)
                nextstate <= 3'b5;
              else
                nextstate <= 3'b2;
            end
            else
              nextstate <= state;
          end
        // Last mont state
        3'b5:
          if (mont_done)
            nextstate <= 3'b6;
          else
            nextstate <= state;
        //Done state
        3'b6:
          nextstate <=3'b0;
        default: nextstate <= 3'b0;
        endcase
      end

    // Control path
    always @(*)
    begin
      case (state)
        // Idle state
        3'b0:
          begin
            mont_resetn  <= 1'b0;
            loop         <= 1'b0;
            end_loop     <= 1'b0;
            count_enable <= 1'b0;
          end
        // X tilde state
        3'b1:
          begin
            mont_resetn  <= 1'b1;
            loop         <= 1'b0;
            end_loop     <= 1'b0;
            count_enable <= 1'b0;
          end
        // Loop state 1
        3'b2:
          begin
            mont_resetn  <= 1'b1;
            loop         <= 1'b1;
            end_loop     <= 1'b0;
            count_enable <= 1'b1;
          end
        // Loop state 2 e[t] = 1
        3'b3:
          begin
            mont_resetn  <= 1'b1;
            loop         <= 1'b1;
            end_loop     <= 1'b0;
            count_enable <= 1'b0;
          end
        // Loop state 2 e[t] = 0
        3'b4:
          begin
            mont_resetn  <= 1'b1;
            loop         <= 1'b1;
            end_loop     <= 1'b0;
            count_enable <= 1'b0;
          end
        // Last mont state
        3'b5:
          begin
            mont_resetn  <= 1'b1;
            loop         <= 1'b0;
            end_loop     <= 1'b1;
            count_enable <= 1'b0;
          end
        // Done state
        3'b6:
          begin
            mont_resetn  <= 1'b1;
            loop         <= 1'b0;
            end_loop     <= 1'b1;
            count_enable <= 1'b0;
          end
        default :
          begin
            mont_resetn  <= 1'b0;
            loop         <= 1'b0;
            end_loop     <= 1'b0;
            count_enable <= 1'b0;
          end
      endcase
    end

endmodule
