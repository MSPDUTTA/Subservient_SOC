package subservient_package;
  
`include "$script_dir/../../verilog/rtl/subservient/serv_state.v"
`include 	$script_dir/../../verilog/rtl/subservient/serv_decode.v"
`include 	$script_dir/../../verilog/rtl/subservient/serv_immdec.v"
`include 	$script_dir/../../verilog/rtl/subservient/serv_bufreg.v"
`include 	$script_dir/../../verilog/rtl/subservient/serv_ctrl.v"
`include 	$script_dir/../../verilog/rtl/subservient/serv_alu.v"
`include 	$script_dir/../../verilog/rtl/subservient/serv_rf_if.v"
`include 	$script_dir/../../verilog/rtl/subservient/serv_mem_if.v"
`include 	$script_dir/../../verilog/rtl/subservient/serv_rf_ram_if.v"
`include 	$script_dir/../../verilog/rtl/subservient/serv_csr.v"
`include 	$script_dir/../../verilog/rtl/subservient/subservient_rf_ram_if.v"
`include 	$script_dir/../../verilog/rtl/subservient/subservient_ram.v"
`include 	$script_dir/../../verilog/rtl/subservient/debug_switch.v"
`include 	$script_dir/../../verilog/rtl/subservient/serv_top.v"
`include 	$script_dir/../../verilog/rtl/subservient/serving_mux.v"
`include 	$script_dir/../../verilog/rtl/subservient/serving_arbiter.v"
`include 	$script_dir/../../verilog/rtl/subservient/subservient_core.v"
`include 	$script_dir/../../verilog/rtl/subservient/subservient_gpio.v"
`include 	$script_dir/../../verilog/rtl/subservient/subservient_top_level.v"
  
endpackage 
