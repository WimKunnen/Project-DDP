`timescale 1ns / 1ps

module rsa_wrapper
(
    // The clock
    input clk,
    // Active low reset
    input resetn,
    
    // data_* is used to communicate 1024-bit chunks of data with the ARM
    // A BRAM interface receives data from data_out and writes it into BRAM.
    // The BRAM interface can also receive data from DMA, 
    //   and then write it to BRAM.

    /// bram_din receives data from ARM
    
        // Data is read in 1024-bit chunks from DMA.
        input [1023:0] bram_din,
        // Indicates that "bram_din" is valid and can be processed by the FSM    
        input bram_din_valid,
    
    /// data_out writes results to ARM
    
        // The result of a computation is stored in data_out. 
        // Only write to "data_out" if you want to store the result
        // of a computation in memory that can be accessed by the ARM 
        output [1023:0] bram_dout,
        // Indicates that there is a valid data in "bram_dout" 
        // that can be written out to memory
        output bram_dout_valid,
        // After asserting "bram_dout_valid", 
        // wait for the BRAM interface to read it,
        // so wait for "bram_dout_read" to become high before continuing 
        input bram_dout_read,
    
    /// P1 is to receive commands from the ARM
    
        // The data received from port1
        input [31:0] port1_din,
        // Indicates that new data (command) is available on port1
        input port1_valid,
        // Assert "port1_data_read" when the data (command) 
        //    from "port1_data" has been read .
        // This allows new data to arrive on port1
        output port1_read,
    
    /// P2 is to assert "Done" signal to ARM 
    
        // Indicates on port2 that the operation is complete/done 
        output port2_valid, 
        // You should wait until your "port2_valid" signal is read
        // so wait for "port2_read" to become high
        input port2_read,
    
    /// Outputs to LEDs for debugging

        output [3:0] leds
    );

    ////////////// - State Machine 

    /// - State Machine Parameters

    localparam STATE_BITS           = 3;    
    localparam STATE_COMPUTE        = 3'h1;
    localparam STATE_WRITE_DATA_OUT = 3'h2;
    localparam STATE_WRITE_PORT2    = 3'h3;
    localparam STATE_READ_DATA      = 3'h4;
    localparam STATE_WRITE_DATA     = 3'h5;
    localparam STATE_WAIT_FOR_CMD   = 3'h6;    

    reg [STATE_BITS-1:0] r_state;
    reg [STATE_BITS-1:0] next_state;
    
    localparam CMD_READ             = 32'h0;
    localparam CMD_COMPUTE          = 32'h1;    
    localparam CMD_WRITE            = 32'h2;

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
                        if (port1_valid==1'b1) begin
                            //Decode the command received on Port1
                            case (port1_din)
                                CMD_READ:
                                    next_state <= STATE_READ_DATA;
                                CMD_COMPUTE:                            
                                    next_state <= STATE_COMPUTE;                                
                                CMD_WRITE: 
                                    next_state <= STATE_WRITE_DATA;
                                default:
                                    next_state <= r_state;
                            endcase;
                        end else
                            next_state <= r_state;
                    end
                
                STATE_READ_DATA:
                    //Read the bram_din and store in r_tmp
                    next_state <= (bram_din_valid==1'b1) ? STATE_WRITE_PORT2 : r_state;
                
                STATE_COMPUTE: 
                    next_state <= STATE_WRITE_PORT2;
                
                STATE_WRITE_DATA:
                    //Write r_tmp to bram_dout
                    next_state <= (bram_dout_read==1'b1) ? STATE_WRITE_PORT2 : r_state;
                
                STATE_WRITE_PORT2:
                    //Write a 'done' to Port2
                    next_state <= (port2_read==1'b1) ? STATE_WAIT_FOR_CMD : r_state;

                default:
                    next_state <= r_state;
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

    reg [1023:0]  core_data;
    
    assign accel_din = core_data;

    always @(posedge(clk))
        if (resetn==1'b0)
        begin
            core_data <= 1024'b0;
        end
        else
        begin
            case (r_state)
                STATE_READ_DATA: begin
                    if ((bram_din_valid==1'b1)) core_data <= bram_din;
                    else                        core_data <= core_data; 
                end
                
                STATE_COMPUTE: begin
                    // XORs the most significant word in the core_data
                    core_data <= {core_data[1023:992]^32'hDEADBEEF, core_data[991:0]};
                end
                default: begin
                    core_data <= core_data;
                end
                
            endcase;
        end
    
    assign bram_dout       = core_data;   

    ////////////// - Valid signals for notifying that the computation is done

    // Computation is done for Core
    reg r_bram_dout_valid;
    always @(posedge(clk))
    begin
        r_bram_dout_valid <= (r_state==STATE_WRITE_DATA);
    end

    assign bram_dout_valid = r_bram_dout_valid;

    ////////////// - Port handshake
    
    reg r_port2_valid;
    reg r_port1_read;
    always @(posedge(clk))
    begin        
        r_port2_valid      <= (r_state==STATE_WRITE_PORT2);
        r_port1_read       <= ((port1_valid==1'b1) & (r_state==STATE_WAIT_FOR_CMD));
    end
              
    assign port1_read       = r_port1_read;
    assign port2_valid      = r_port2_valid; 

    ////////////// - Debugging signals
    
    // The four LEDs on the board are used as debug signals.
    // Here they are used to check the state transition.

    assign leds             = r_state;

endmodule
