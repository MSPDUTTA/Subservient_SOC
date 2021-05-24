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
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */

module user_project_wrapper #(
    parameter BITS = 32
) (
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

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    inout [`MPRJ_IO_PADS-10:0] analog_io,

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

/*--------------------------------------*/
/* User project is instantiated  here   */
/*--------------------------------------*/

    parameter memsize = 8192;
    parameter aw    = 13; //$clog2(memsize);

    wire  q;
  
    wire [aw-1:0] sram_waddr;
    wire [7:0]   sram_wdata;
    wire         sram_wen;
    wire [aw-1:0] sram_raddr;
    wire [7:0]   sram_rdata;
    wire         sram_ren;
    // IO
    wire deb_mode;
    
    // IRQ
    assign user_irq = 3'b000;        

    assign io_out = q;
    // LA
    assign la_data_out =  q;

   wire [1:0] sram_bsel;
   assign sram_bsel  = sram_raddr[1:0];

   assign deb_mode = 1'b1;
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
      .clk0   (wb_clk_i),
      .csb0   (!sram_wen),
      .web0   (1'b0),
      .wmask0 (wmask0),
      .addr0  (waddr0),
      .din0   (din0),
      .dout0  (),
      .clk1   (wb_clk_i),
      .csb1   (!sram_ren),
      .addr1  (addr1),
      .dout1  (dout1));


   subservient
     #(.memsize  (memsize),
       .WITH_CSR (0))
   dut
     (// Clock & reset
      .i_clk (wb_clk_i),
      .i_rst (wb_rst_i),

      //SRAM interface
      .o_sram_waddr (sram_waddr),
      .o_sram_wdata (sram_wdata),
      .o_sram_wen   (sram_wen),
      .o_sram_raddr (sram_raddr),
      .i_sram_rdata (sram_rdata),
      .o_sram_ren   (sram_ren),

      //Debug interface
      .i_debug_mode (deb_mode),
      .i_wb_dbg_adr (wbs_adr_i),
      .i_wb_dbg_dat (wbs_dat_i),
      .i_wb_dbg_sel (wbs_sel_i),
      .i_wb_dbg_we  (wbs_we_i),
      .i_wb_dbg_stb (wbs_stb_i),
      .o_wb_dbg_rdt (wbs_dat_o),
      .o_wb_dbg_ack (wbs_ack_o),

      // External I/O
      .o_gpio (q));



endmodule	// user_project_wrapper

`default_nettype wire
