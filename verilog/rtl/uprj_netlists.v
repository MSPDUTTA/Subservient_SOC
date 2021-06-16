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

// Include caravel global defines for the number of the user project IO pads 
`include "defines.v"
`define USE_POWER_PINS

`ifdef GL
    // Assume default net type to be wire because GL netlists don't have the wire definitions
    `default_nettype wire
    `include "gl/user_project_wrapper.v"
    `include "gl/sky130_sram_1kbyte_1rw1r_32x256_8.v"
`else
    `include "user_project_wrapper.v"
    `include "sky130_sram_1kbyte_1rw1r_32x256_8.v"
    `include "subservient/serv_state.v"
    `include 	"subservient/serv_decode.v"
    `include 	"subservient/serv_immdec.v"
    `include 	"subservient/serv_bufreg.v"
    `include 	"subservient/serv_ctrl.v"
    `include 	"subservient/serv_alu.v"
    `include 	"subservient/serv_rf_if.v"
    `include 	"subservient/serv_mem_if.v"
    `include 	"subservient/serv_rf_ram_if.v"
    `include 	"subservient/serv_csr.v"
    `include 	"subservient/subservient_rf_ram_if.v"
    `include 	"subservient/subservient_ram.v"
    `include 	"subservient/debug_switch.v"
    `include 	"subservient/serv_top.v"
    `include 	"subservient/serving_mux.v"
    `include 	"subservient/serving_arbiter.v"
    `include 	"subservient/subservient_core.v"
    `include 	"subservient/subservient_gpio.v"
    `include "subservient/subservient_top_level.v"
`endif
