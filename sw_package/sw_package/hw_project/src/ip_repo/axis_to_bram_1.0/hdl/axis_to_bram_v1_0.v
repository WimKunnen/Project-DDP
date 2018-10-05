
`timescale 1 ns / 1 ps

	module axis_to_bram_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 32,
        parameter integer BRAM_DATA_WIDTH       = 32,
		parameter integer BRAM_ADDR_WIDTH       = 10
	)
	(
		// Users to add ports here    
	    output wire [BRAM_ADDR_WIDTH-1 : 0] bram_addr,
        output wire bram_clk,
        output wire [BRAM_DATA_WIDTH-1 : 0] bram_din,
        //input wire bram_dout, //Not used        
        output wire bram_en,
        output wire bram_rst,
        output wire bram_we,

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXIS
		input wire  s00_axis_aclk,
		input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid
	);
// Instantiation of Axi Bus Interface S00_AXIS
	axis_to_bram_v1_0_S00_AXIS # ( 
		.C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH),
		.BRAM_ADDR_WIDTH(BRAM_ADDR_WIDTH)
	) stream_to_bram2_v1_0_S00_AXIS_inst (
        .bram_addr(bram_addr),
        .bram_clk(bram_clk),
        .bram_din(bram_din),
        .bram_en(bram_en),
        .bram_rst(bram_rst),
        .bram_we(bram_we),
        .S_AXIS_ACLK(s00_axis_aclk),
		.S_AXIS_ARESETN(s00_axis_aresetn),
		.S_AXIS_TREADY(s00_axis_tready),
		.S_AXIS_TDATA(s00_axis_tdata),
		.S_AXIS_TLAST(s00_axis_tlast),
		.S_AXIS_TVALID(s00_axis_tvalid)
	);

	// Add user logic here

	// User logic ends

	endmodule
