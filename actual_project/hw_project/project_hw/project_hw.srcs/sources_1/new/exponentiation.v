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
    output reg           done
    );
    
    // ############
    // # Datapath #
    // ############

    // Montgomery instance and relevant wires.
    reg mont_resetn;
    reg mont_start;
    wire [1023:0] mont_input_a;
    wire [1023:0] mont_input_b;
    wire [1023:0] mont_input_m;
    wire [1023:0] mont_result;
    wire mont_done;
        
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

    // Registers
    reg input_en;

    reg [9:0] t;
    reg t_count_en;

    always @(posedge clk)
    begin
	    if (input_en == 1)
		    t <= in_t;
	    else if (t_count_en == 1)
		    t <= t - 1;
    end

    reg [1023:0] a;
    reg a_en;
    reg a_sel;
    wire [1023:0] a_input;
    assign a_input = a_sel == 1 ? in_r : mont_result;
    assign result = a;

    reg [1023:0] x;
    reg x_en;
    
    reg [1023:0] e;
    reg e_en;
    wire [1023:0] e_input;
    reg e_sel;
    assign e_input = (e_sel == 1) ? in_e : {1'b0, e[1023:1]};

    always @(posedge clk)
    begin
	    if (e_en == 1)
		    e <= e_input;
    end

    reg [1023:0] mont_a;
    reg [1023:0] mont_b;
    
    reg mont_a_sel;
    reg [1:0] mont_b_sel;
            
    // Montgomery input multiplexers
    wire [1023:0] const_one;
    assign const_one = 1024'h1;

    assign mont_input_a = mont_a_sel == 1 ? in_x : a;
    assign mont_input_b = mont_b_sel[1] == 1 ? (mont_b_sel[0] == 1 ? in_r2 : a) : (mont_b_sel[0] == 1 ? x : const_one);
    
    // Result registers    
    always @(posedge clk)
    begin
        if (resetn == 0)
        begin
            x <= 0;
            a <= 0;
        end
        else begin
            if (x_en == 1)
                x <= mont_result;
            if (a_en == 1)
                a <= a_input;
        end
    end
    
    // #######
    // # FSM #
    // #######
    
    reg [3:0] state, nextstate;
    
    // Reset
    always @(posedge clk)
    begin
        if(resetn==0)
            state <= 4'd0;
        else
            state <= nextstate;
    end
        
    
    // Control signals
    always @(posedge clk)
    begin
        case(state)
            // Idle state, store R in a on start;
            4'd0: begin
		    mont_start <= 0;
            mont_resetn <= 0;
            done <= 0;
		    e_sel <= 1;
		    x_en <= 0;
		    mont_a_sel <= 0;
		    mont_b_sel <= 2'b00;
            if (start == 1)
            begin
			 a_sel <= 1;
			 a_en <= 1;
			 input_en <= 1;
			 e_en <= 1;
            end
		    else
		    begin
			 a_sel <= 0;
			 a_en <= 0;
			 input_en <= 0;
			 e_en <= 0;
            end


            end
            // Start x tilde calculation.
            4'd1:
            begin
		    a_sel <= 0;
		    input_en <= 0;
		    e_en <= 0;
		    e_sel <= 0;
                mont_resetn <= 1;
                mont_a_sel <= 1;
                mont_b_sel <= 2'b11;
                mont_start <= 1;
                a_en <= 0;
            end
            // Wait x tilde calculation
            4'd2:
            begin
                mont_resetn <= 1;
                mont_start <= 0;
                x_en <= mont_done;
            end
	    // Start loop, start a = mont(a,a)
            4'd3:
            begin
                x_en <= 0;
		    a_en <= 0;
		    e_sel <= 0;
		    e_en <= 0;
		    mont_a_sel <= 0;
		    mont_b_sel <= 2'b10;
		    mont_start <= 1;
		    t_count_en <= 1;
            end
	    // Wait a = mont(a,a) calculation
	    4'd4:
	    begin
		    mont_start <= 0;
		    t_count_en <= 0;
		    a_en <= mont_done;
	    end
	    // Start a = mont(a, x)
	    4'd5:
	    begin
		    mont_a_sel <= 0;
		    mont_b_sel <= 2'b01;
		    mont_start <= 1;
	    end
	    // Wait a = mont(a, x)
	    4'd6:
	    begin
		    mont_start <= 0;
		    a_sel <= 0;
		    e_en <= mont_done;
		    if (e[0] == 1)
		    begin
			    a_en <= mont_done;
		    end
		    else
			    a_en <= 0;
	    end
	    // Start a = mont(a, 1)
	    4'd7:
	    begin
		    mont_a_sel <= 0;
		    mont_b_sel <= 2'b00;
		    mont_start <= 1;
		    a_en <= 0;
		    e_en <= 0;
	    end
	    // Wait a = mont(a, 1)
	    4'd8:
	    begin
		    mont_start <= 0;
		    a_sel <= 0;
		    a_en <= mont_done;
	    end
	    // Done
	    4'd9:
	    begin
		    a_en <= 0;
		    done <= 1;
	    end
            default:
            begin
                mont_resetn <= 0;
             end
        endcase
    end
    
    // Next state logic
    always @(*)
    begin
        case(state)
            // Idle state
            4'd0:
            begin
                if (start == 1)
                    nextstate <= 4'd1;
                else
                    nextstate <= state;
            end
            // Start x tilde calculation.
            4'd1:
            begin
                nextstate <= 4'd2;
            end
            // Wait x tilde calculation.
            4'd2:
            begin
                if (mont_done)
                    nextstate <= 4'd3;
                else
                    nextstate <= state;
            end
	    // Start loop, a = mont(a,a)
	    4'd3:
	    begin
		    nextstate <= 4'd4;
	    end
	    // Wait a = mont(a,a) calculation
	    4'd4:
	    begin
		if (mont_done)
			nextstate <= 4'd5;
		else
                    nextstate <= state;
	    end
	    // Start mont(a,x) calculation
	    4'd5:
	    begin
		    nextstate <= 4'd6;
	    end
	    // Wait mont(a,x) calculation
	    4'd6:
	    begin
		    if (mont_done == 1)
		    begin
			    if (t == 0)
				    nextstate <= 4'd7;
			    else
				    nextstate <= 4'd3;
		    end
		    else
			    nextstate <= state;
	    end
	    // Start a = mont(a,1)
	    4'd7:
	    begin
		    nextstate <= 4'd8;
	    end
	    // Wait a = mont(a, 1)
	    4'd8:
	    begin
		    if (mont_done == 1)
			    nextstate <= 4'd9;
		    else
			    nextstate <= state;
	    end
	    // Done
	    4'd9:
	    begin
		    nextstate <= 4'd0;
	    end
            // Default state
            default:
            begin
                nextstate <= 4'd0;
            end
        endcase
    end

endmodule
