    `timescale 1 ns / 1 ps

	module Accelerator_Interface #
	(
		// Parameters of Axi Slave Bus Interface S00_AXI
        parameter integer C_S00_AXI_ID_WIDTH     = 1,
        parameter integer C_S00_AXI_DATA_WIDTH   = 32,
        parameter integer C_S00_AXI_ADDR_WIDTH   = 32,
        parameter integer C_S00_AXI_AWUSER_WIDTH = 0,
        parameter integer C_S00_AXI_ARUSER_WIDTH = 0,
        parameter integer C_S00_AXI_WUSER_WIDTH  = 0,
        parameter integer C_S00_AXI_RUSER_WIDTH  = 0,
        parameter integer C_S00_AXI_BUSER_WIDTH  = 0,
        
        // Parameters of Axi Slave Bus Interface S01_AXI
        parameter integer C_S01_AXI_ID_WIDTH     = 1,
        parameter integer C_S01_AXI_DATA_WIDTH   = 32,
        parameter integer C_S01_AXI_ADDR_WIDTH   = 32,
        parameter integer C_S01_AXI_AWUSER_WIDTH = 0,
        parameter integer C_S01_AXI_ARUSER_WIDTH = 0,
        parameter integer C_S01_AXI_WUSER_WIDTH  = 0,
        parameter integer C_S01_AXI_RUSER_WIDTH  = 0,
        parameter integer C_S01_AXI_BUSER_WIDTH  = 0,
        
        parameter integer BRAM_ADDR_WIDTH        = 10,
        parameter integer BRAM_DATA_WIDTH        = 32,
        parameter integer BRAM_WORD_COUNT        = 32,        
        parameter integer BRAM_CLK_LATENCY       = 1
    )
	(
	
	input wire  s00_axi_aclk,
    input wire  s00_axi_aresetn,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
    input wire [2 : 0] s00_axi_awprot,
    input wire  s00_axi_awvalid,
    output wire  s00_axi_awready,
    input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
    input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
    input wire  s00_axi_wvalid,
    output wire  s00_axi_wready,
    output wire [1 : 0] s00_axi_bresp,
    output wire  s00_axi_bvalid,
    input wire  s00_axi_bready,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input wire [2 : 0] s00_axi_arprot,
    input wire  s00_axi_arvalid,
    output wire  s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [1 : 0] s00_axi_rresp,
    output wire  s00_axi_rvalid,
    input wire  s00_axi_rready,
            
    input wire  s01_axi_aclk,
    input wire  s01_axi_aresetn,
    input wire [C_S01_AXI_ADDR_WIDTH-1 : 0] s01_axi_awaddr,
    input wire [2 : 0] s01_axi_awprot,
    input wire  s01_axi_awvalid,
    output wire  s01_axi_awready,
    input wire [C_S01_AXI_DATA_WIDTH-1 : 0] s01_axi_wdata,
    input wire [(C_S01_AXI_DATA_WIDTH/8)-1 : 0] s01_axi_wstrb,
    input wire  s01_axi_wvalid,
    output wire  s01_axi_wready,
    output wire [1 : 0] s01_axi_bresp,
    output wire  s01_axi_bvalid,
    input wire  s01_axi_bready,
    input wire [C_S01_AXI_ADDR_WIDTH-1 : 0] s01_axi_araddr,
    input wire [2 : 0] s01_axi_arprot,
    input wire  s01_axi_arvalid,
    output wire  s01_axi_arready,
    output wire [C_S01_AXI_DATA_WIDTH-1 : 0] s01_axi_rdata,
    output wire [1 : 0] s01_axi_rresp,
    output wire  s01_axi_rvalid,
    input wire  s01_axi_rready,
    
    //BRAM interface
    input  [BRAM_ADDR_WIDTH-1:0] bram_addr,
    input  [BRAM_DATA_WIDTH-1:0] bram_din,
    input                        bram_we,
    input                        bram_en,
    
    // Connections to montgomery wrapper
    output          mw_clk,            
    output          mw_resetn,
    output [1023:0] mw_bram_din,
    output          mw_bram_din_valid,
    input  [1023:0] mw_bram_dout,
    input           mw_bram_dout_valid,
    output          mw_bram_dout_read,
    output [31:0]   mw_port1_din,
    output          mw_port1_valid,
    input           mw_port1_read,
    input           mw_port2_valid,
    output          mw_port2_read
	);
  
    /*****************These signals are connected to montgomery_wrapper*******************/
    wire [1023:0] data_in;
    wire [1023:0] data_out;
    wire data_out_valid;
    wire data_in_valid;

    wire [31:0] port1_data;
    wire port1_data_valid;
    wire port1_data_read;
    wire port2_data_valid;
    wire port2_data_read;

    assign mw_clk              = s00_axi_aclk;
    assign mw_resetn           = s00_axi_aresetn;
    assign mw_bram_din         = data_in;
    assign mw_bram_din_valid   = data_in_valid;
    assign data_out            = mw_bram_dout;
    assign data_out_valid      = mw_bram_dout_valid;
    assign mw_bram_dout_read   = data_out_read;
    assign mw_port1_din        = port1_data;
    assign mw_port1_valid      = port1_data_valid;
    assign port1_data_read     = mw_port1_read;
    assign port2_data_valid    = mw_port2_valid;
    assign mw_port2_read       = port2_data_read;

// Instantiation of Axi Bus Interface S00_AXI
	my_montgomery_port_slave_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) myip_port_slave_inst (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),
        .PORT1_DATA(port1_data),
        .PORT1_DATA_VALID(port1_data_valid),
        .PORT1_DATA_READ(port1_data_read),
        //.PORT2_DATA(port2_data),
        .PORT2_DATA_VALID(port2_data_valid),
        .PORT2_DATA_READ(port2_data_read)
	);
	
	myip_axilite_data_slave # ( 
            .C_S_AXI_DATA_WIDTH(C_S01_AXI_DATA_WIDTH),
            .C_S_AXI_ADDR_WIDTH(C_S01_AXI_ADDR_WIDTH),
            .REG_DATA_WIDTH(1024)
    ) myip_data_slave_inst (
            .S_AXI_ACLK(s01_axi_aclk),
            .S_AXI_ARESETN(s01_axi_aresetn),
            .S_AXI_AWADDR(s01_axi_awaddr),
            .S_AXI_AWPROT(s01_axi_awprot),
            .S_AXI_AWVALID(s01_axi_awvalid),
            .S_AXI_AWREADY(s01_axi_awready),
            .S_AXI_WDATA(s01_axi_wdata),
            .S_AXI_WSTRB(s01_axi_wstrb),
            .S_AXI_WVALID(s01_axi_wvalid),
            .S_AXI_WREADY(s01_axi_wready),
            .S_AXI_BRESP(s01_axi_bresp),
            .S_AXI_BVALID(s01_axi_bvalid),
            .S_AXI_BREADY(s01_axi_bready),
            .S_AXI_ARADDR(s01_axi_araddr),
            .S_AXI_ARPROT(s01_axi_arprot),
            .S_AXI_ARVALID(s01_axi_arvalid),
            .S_AXI_ARREADY(s01_axi_arready),
            .S_AXI_RDATA(s01_axi_rdata),
            .S_AXI_RRESP(s01_axi_rresp),
            .S_AXI_RVALID(s01_axi_rvalid),
            .S_AXI_RREADY(s01_axi_rready),
            .data_in(data_in)
    );

    ram_verilog #
    (
        .BRAM_ADDR_WIDTH(BRAM_ADDR_WIDTH)
    )
    
    ram_verilog_inst
    (
        .clk            (s00_axi_aclk),     
        .resetn         (s00_axi_aresetn),

        .din_sw_addr    (bram_addr),        // Address Input
        .din_sw         (bram_din),         // Data bi-directional
        .din_sw_we      (bram_we),          // Write Enable

        .din_hw         (data_out),         // 1024 bit data input in parallel
        .din_hw_read    (data_out_read),
        .din_hw_we      (data_out_valid),   // Write enable in portb

        .dout_hw        (data_in),          // 1024 bit data output for reading
        .dout_hw_valid  (data_in_valid)
    );

	endmodule
