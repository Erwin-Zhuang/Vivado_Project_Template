//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.2 (win64) Build 6299465 Fri Nov 14 19:35:11 GMT 2025
//Date        : Thu Mar  5 21:13:29 2026
//Host        : MikeyHaus running 64-bit major release  (build 9200)
//Command     : generate_target block_design_wrapper.bd
//Design      : block_design_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module block_design_wrapper
   (clk,
    dout,
    rst);
  input clk;
  output dout;
  input rst;

  wire clk;
  wire dout;
  wire rst;

  block_design block_design_i
       (.clk(clk),
        .dout(dout),
        .rst(rst));
endmodule
