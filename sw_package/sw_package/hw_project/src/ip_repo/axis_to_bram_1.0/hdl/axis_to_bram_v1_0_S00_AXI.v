`timescale 1 ns / 1 ps

module axis_to_bram_v1_0_S00_AXIS #
(
    parameter integer C_S_AXIS_TDATA_WIDTH    = 32,
    parameter integer BRAM_ADDR_WIDTH       = 10
)
(
    // Users to add ports here      
    output wire [BRAM_ADDR_WIDTH-1 : 0] bram_addr,
    output wire bram_clk,
    output wire [C_S_AXIS_TDATA_WIDTH-1 : 0] bram_din,        
    output wire bram_en,
    output wire bram_rst,
    output wire bram_we,
    // User ports ends
    
    // Do not modify the ports beyond this line

    // AXI4Stream sink: Clock
    input wire  S_AXIS_ACLK,
    // AXI4Stream sink: Reset
    input wire  S_AXIS_ARESETN,
    // Ready to accept data in
    output wire  S_AXIS_TREADY,
    // Data in
    input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
    // Indicates boundary of last packet
    input wire  S_AXIS_TLAST,
    // Data is in valid
    input wire  S_AXIS_TVALID
);

wire      axis_tready;
genvar byte_index;     
wire axis_valid_and_ready;
reg [BRAM_ADDR_WIDTH-1:0] write_pointer;
reg writes_done;

assign S_AXIS_TREADY    = axis_tready;

assign axis_tready = 1'b1;

always@(posedge S_AXIS_ACLK)
begin
  if(!S_AXIS_ARESETN)
    begin
      write_pointer <= 0;
      writes_done <= 1'b0;
    end  
  else
    if (S_AXIS_TVALID && axis_tready)
      begin
        write_pointer <= write_pointer + 1;                

        if (S_AXIS_TLAST==1'b1)
        begin
            writes_done <= 1'b1;
            write_pointer <= 0;
        end
        else
        begin
            writes_done <= 1'b0;
        end                
      end
end

assign axis_valid_and_ready = S_AXIS_TVALID && axis_tready;    
assign bram_addr = write_pointer*(C_S_AXIS_TDATA_WIDTH/8);
assign bram_clk = S_AXIS_ACLK;
assign bram_din = S_AXIS_TDATA;
assign bram_en = 1'b1; //TODO: Disable when not writing to BRAM
assign bram_rst = ~S_AXIS_ARESETN;
assign bram_we = axis_valid_and_ready;

endmodule
