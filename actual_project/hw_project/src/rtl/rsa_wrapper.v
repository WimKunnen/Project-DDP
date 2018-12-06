`timescale 1ns / 1ps

module rsa_wrapper
(
    // The clock and active low reset
    input           clk,
    input           resetn,
    
    input  [  31:0] arm_to_fpga_cmd,
    input           arm_to_fpga_cmd_valid,
    output          arm_to_fpga_done,
    input           arm_to_fpga_done_read,

    input           arm_to_fpga_data_valid,
    output          arm_to_fpga_data_ready,
    input  [1023:0] arm_to_fpga_data,
    
    output          fpga_to_arm_data_valid,
    input           fpga_to_arm_data_ready,
    output [1023:0] fpga_to_arm_data,
    
    output [   3:0] leds

    );
    
    // Exponentiation instance
    reg exp_start;
    wire exp_done;
    wire [1023:0] exp_result;
    
    reg [1023:0] x;
    reg [1023:0] e;
    reg [1023:0] r2;
    reg [1023:0] r;
    reg [1023:0] m;
    reg [9:0] t;
    reg [1023:0] result;
    reg [1023:0] out_data;
    
    exponentiation exp(
        .clk(clk),
        .resetn(resetn),
        .start(exp_start),
        .in_x(x),
        .in_r(r),
        .in_r2(r2),
        .in_m(m),
        .in_e(e),
        .in_t(t),
        .result(exp_result),
        .done(exp_done)
        );

    ////////////// - State Machine 

    /// - State Machine Parameters

    localparam STATE_BITS           = 3;
    localparam STATE_WAIT_FOR_CMD   = 3'd0;  
    localparam STATE_READ_DATA      = 3'd1;
    localparam STATE_COMPUTE        = 3'd2;
    localparam STATE_WAIT_COMPUTE   = 3'd3;
    localparam STATE_WRITE_DATA     = 3'd4;
    localparam STATE_ASSERT_DONE    = 3'd5;
    

    reg [STATE_BITS-1:0] r_state;
    reg [STATE_BITS-1:0] next_state;
    
    localparam CMD_COMPUTE          = 32'd0;
    localparam CMD_READ_X           = 32'd1;
    localparam CMD_READ_E           = 32'd3;
    localparam CMD_READ_R           = 32'd5;
    localparam CMD_READ_R2          = 32'd7;
    localparam CMD_READ_M           = 32'd9;
    localparam CMD_WRITE_RESULT     = 32'd2;
    localparam CMD_WRITE_X          = 32'd4;
    localparam CMD_WRITE_E          = 32'd6;
    localparam CMD_WRITE_M          = 32'd8;
    localparam CMD_WRITE_R          = 32'd10;
    localparam CMD_WRITE_R2         = 32'd12;
    
    assign fpga_to_arm_data = out_data;

    /// - State Transition

    always @(*)
    begin
        if (resetn==1'b0)
            next_state <= STATE_WAIT_FOR_CMD;
        else
        begin
            case (r_state)
                STATE_WAIT_FOR_CMD:
                    begin
                        if (arm_to_fpga_cmd_valid) begin
                            case (arm_to_fpga_cmd[0])
                                1'b0:
                                case(arm_to_fpga_cmd[21:0])
                                    22'd0:
                                        next_state <= STATE_COMPUTE;
                                    22'd2: 
                                        next_state <= STATE_WRITE_DATA;
                                    22'd4:
                                        next_state <= STATE_WRITE_DATA;
                                    22'd6:
                                        next_state <= STATE_WRITE_DATA;
                                    22'd8:
                                        next_state <= STATE_WRITE_DATA;
                                    22'd10:
                                        next_state <= STATE_WRITE_DATA;
                                    22'd12:
                                        next_state <= STATE_WRITE_DATA;
                                    default:
                                        next_state <= STATE_WAIT_FOR_CMD;
                                endcase                      
                                1'b1:
                                    next_state <= STATE_READ_DATA;
                                default:
                                    next_state <= r_state;    
                            endcase;
                        end else
                            next_state <= r_state;
                    end

                STATE_READ_DATA:
                    next_state <= (arm_to_fpga_data_valid) ? STATE_ASSERT_DONE : r_state;
                                
                STATE_COMPUTE: 
                    next_state <= STATE_WAIT_COMPUTE;
                    
                STATE_WAIT_COMPUTE:
                    if (exp_done == 1)
                        next_state <= STATE_ASSERT_DONE;
                    else
                        next_state <= r_state;      

                STATE_WRITE_DATA:
                    next_state <= (fpga_to_arm_data_ready) ? STATE_ASSERT_DONE : r_state;

                STATE_ASSERT_DONE:
                    next_state <= (arm_to_fpga_done_read) ? STATE_WAIT_FOR_CMD : r_state;

                default:
                    next_state <= STATE_WAIT_FOR_CMD;
            endcase
        end
    end

    /// - Synchronous State Update

    always @(posedge(clk))
        if (resetn==1'b0)
            r_state <= STATE_WAIT_FOR_CMD;
        else
            r_state <= next_state;   

    ////////////// - Computation
        
    always @(posedge(clk))
        if (resetn==1'b0)
        begin
            result <= 1024'b0;
        end
        else
        begin
            case (r_state)
                STATE_READ_DATA: begin
                    if (arm_to_fpga_data_valid) begin
                        case(arm_to_fpga_cmd[3:1])
                            3'b000:
                                x <= arm_to_fpga_data;
                            3'b001:
                                e <= arm_to_fpga_data;
                            3'b010:
                                r <= arm_to_fpga_data;
                            3'b011:
                                r2 <= arm_to_fpga_data;
                            3'b100:
                                m <= arm_to_fpga_data;
                        endcase
                    end
                end
                
                STATE_COMPUTE: begin
                    t <= arm_to_fpga_cmd[31:22];
                    exp_start <= 1;
                end
                
                STATE_WAIT_COMPUTE: begin
                    exp_start <= 0;
                    if (exp_done == 1)
                        result <= exp_result;
                end
                
                STATE_WRITE_DATA: begin
                    case(arm_to_fpga_cmd)
                        CMD_WRITE_RESULT:
                            out_data <= result;
//                        CMD_WRITE_X:
//                            out_data <= x;
//                        CMD_WRITE_E:
//                            out_data <= e;
                        CMD_WRITE_M:
                            out_data <= m;
                        CMD_WRITE_R:
                            out_data <= r;
//                        CMD_WRITE_R2:
//                            out_data <= r2;
                        default:
                            out_data <= result;
                    endcase
                end
                
                default: begin
                    x <= x;
                    e <= e;
                    r <= r;
                    r2 <= r2;
                    m <= m;
                    t <= t;
                    out_data <= 0;
                end
                
            endcase;
        end

    ////////////// - Valid signals for notifying that the computation is done

    /// - Port handshake

    reg r_fpga_to_arm_data_valid;
    reg r_arm_to_fpga_data_ready;

    always @(posedge(clk)) begin
        r_fpga_to_arm_data_valid <= (r_state==STATE_WRITE_DATA);
        r_arm_to_fpga_data_ready <= (r_state==STATE_READ_DATA);
    end
    
    assign fpga_to_arm_data_valid = r_fpga_to_arm_data_valid;
    assign arm_to_fpga_data_ready = r_arm_to_fpga_data_ready;
    
    /// - Done signal
    
    reg r_arm_to_fpga_done;

    always @(posedge(clk))
    begin        
        r_arm_to_fpga_done <= (r_state==STATE_ASSERT_DONE);
    end

    assign arm_to_fpga_done = r_arm_to_fpga_done;
    
    ////////////// - Debugging signals
    
    // The four LEDs on the board are used as debug signals.
    // Here they are used to check the state transition.

    assign leds             = {1'b0,r_state};

endmodule
