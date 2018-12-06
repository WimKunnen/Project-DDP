// (c) Copyright 1995-2018 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: user.org:module_ref:rsa_wrapper:1.0
// IP Revision: 1

(* X_CORE_INFO = "rsa_wrapper,Vivado 2016.2" *)
(* CHECK_LICENSE_TYPE = "rsa_project_rsa_wrapper_0_0,rsa_wrapper,{}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module rsa_project_rsa_wrapper_0_0 (
  clk,
  resetn,
  arm_to_fpga_cmd,
  arm_to_fpga_cmd_valid,
  arm_to_fpga_done,
  arm_to_fpga_done_read,
  arm_to_fpga_data_valid,
  arm_to_fpga_data_ready,
  arm_to_fpga_data,
  fpga_to_arm_data_valid,
  fpga_to_arm_data_ready,
  fpga_to_arm_data,
  leds
);

(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
input wire clk;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 resetn RST" *)
input wire resetn;
input wire [31 : 0] arm_to_fpga_cmd;
input wire arm_to_fpga_cmd_valid;
output wire arm_to_fpga_done;
input wire arm_to_fpga_done_read;
input wire arm_to_fpga_data_valid;
output wire arm_to_fpga_data_ready;
input wire [1023 : 0] arm_to_fpga_data;
output wire fpga_to_arm_data_valid;
input wire fpga_to_arm_data_ready;
output wire [1023 : 0] fpga_to_arm_data;
output wire [3 : 0] leds;

  rsa_wrapper inst (
    .clk(clk),
    .resetn(resetn),
    .arm_to_fpga_cmd(arm_to_fpga_cmd),
    .arm_to_fpga_cmd_valid(arm_to_fpga_cmd_valid),
    .arm_to_fpga_done(arm_to_fpga_done),
    .arm_to_fpga_done_read(arm_to_fpga_done_read),
    .arm_to_fpga_data_valid(arm_to_fpga_data_valid),
    .arm_to_fpga_data_ready(arm_to_fpga_data_ready),
    .arm_to_fpga_data(arm_to_fpga_data),
    .fpga_to_arm_data_valid(fpga_to_arm_data_valid),
    .fpga_to_arm_data_ready(fpga_to_arm_data_ready),
    .fpga_to_arm_data(fpga_to_arm_data),
    .leds(leds)
  );
endmodule
