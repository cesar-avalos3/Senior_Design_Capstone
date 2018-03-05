// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
// Date        : Sun Mar  4 23:45:32 2018
// Host        : DESKTOP-N7G5341 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               e:/TimmyCore/TimmyCore/TimmyCore.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_stub.v
// Design      : clk_wiz_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_0(clk_100MHz_o, clk_200MHz_o, locked_o, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_100MHz_o,clk_200MHz_o,locked_o,clk_in1" */;
  output clk_100MHz_o;
  output clk_200MHz_o;
  output locked_o;
  input clk_in1;
endmodule
