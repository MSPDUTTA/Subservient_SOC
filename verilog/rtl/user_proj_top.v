// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_top #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vdda1,	// User area 1 3.3V supply
    inout vdda2,	// User area 2 3.3V supply
    inout vssa1,	// User area 1 analog ground
    inout vssa2,	// User area 2 analog ground
    inout vccd1,	// User area 1 1.8V supply
    inout vccd2,	// User area 2 1.8v supply
    inout vssd1,	// User area 1 digital ground
    inout vssd2,	// User area 2 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire rst;
    
    parameter memsize = 8192;
    parameter with_csr = 0;
    parameter aw    = $clog2(memsize);

    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;

    wire [31:0] rdata; 
    wire [31:0] wdata;
    wire [BITS-1:0] count;

    wire valid;
    wire [3:0] wstrb;
    wire [31:0] la_write;

    wire [aw-1:0] sram_waddr;
    wire [7:0] 	 sram_wdata;
    wire 	 sram_wen;
    wire [aw-1:0] sram_raddr;
    wire [7:0] 	 sram_rdata;
    wire 	 sram_ren;


    // WB MI A
    assign valid = wbs_cyc_i && wbs_stb_i; 
    assign wstrb = wbs_sel_i & {4{wbs_we_i}};
    assign wbs_dat_o = rdata;
    assign wdata = wbs_dat_i;

    // IO
    assign io_out = count;
    assign io_oeb = {(`MPRJ_IO_PADS-1){rst}};

    // IRQ
    assign irq = 3'b000;	// Unused

    // LA
    assign la_data_out = {{(127-BITS){1'b0}}, count};
    // Assuming LA probes [63:32] are for controlling the count register  
    assign la_write = ~la_oenb[63:32] & ~{BITS{valid}};
    // Assuming LA probes [65:64] are for controlling the count clk & reset  
    assign clk = (~la_oenb[64]) ? la_data_in[64]: wb_clk_i;
    assign rst = (~la_oenb[65]) ? la_data_in[65]: wb_rst_i;

       //Adapt the 8-bit SRAM interface from subservient to the 32-bit OpenRAM instance
   reg [1:0] sram_bsel;
   always @(posedge clk) begin
      sram_bsel  <= sram_raddr[1:0];
   end

   wire [3:0] wmask0 = 4'd1 << sram_waddr[1:0];
   wire [7:0] waddr0 = sram_waddr[9:2]; //256 32-bit words = 1kB
   wire [31:0] din0 = {4{sram_wdata}}; //Mirror write data to all byte lanes

   wire [7:0]  addr1 = sram_raddr[9:2];
   wire [31:0] dout1;
   assign sram_rdata = dout1[sram_bsel*8+:8]; //Pick the right byte from the read data
   
 sky130_sram_1kbyte_1rw1r_32x256_8
     #(// FIXME: This delay is arbitrary.
       .DELAY (3),
       .VERBOSE (0))
   sram
     (
      .clk0   (clk),
      .csb0   (!sram_wen),
      .web0   (1'b0),
      .wmask0 (wmask0),
      .addr0  (waddr0),
      .din0   (din0),
      .dout0  (),
      .clk1   (clk),
      .csb1   (!sram_ren),
      .addr1  (addr1),
      .dout1  (dout1));


   subservient
     #(.memsize  (memsize),
       .WITH_CSR (with_csr))
   dut
     (// Clock & reset
      .i_clk (clk),
      .i_rst (rst),

      //SRAM interface
      .o_sram_waddr (sram_waddr),
      .o_sram_wdata (sram_wdata),
      .o_sram_wen   (sram_wen),
      .o_sram_raddr (sram_raddr),
      .i_sram_rdata (sram_rdata),
      .o_sram_ren   (sram_ren),

      //Debug interface
      .i_debug_mode (debug_mode),
      .i_wb_dbg_adr (wb_dbg_adr),
      .i_wb_dbg_dat (wb_dbg_dat),
      .i_wb_dbg_sel (wb_dbg_sel),
      .i_wb_dbg_we  (wb_dbg_we ),
      .i_wb_dbg_stb (wb_dbg_stb),
      .o_wb_dbg_rdt (wb_dbg_rdt),
      .o_wb_dbg_ack (wb_dbg_ack),

      // External I/O
      .o_gpio (q));

endmodule


`default_nettype wire
