# Same board clock and K3 pin as the working ego1_led_test.
set_property PACKAGE_PIN P17 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -name sys_clk -period 10.000 [get_ports clk]
create_generated_clock -name cpu_clk -source [get_ports clk] -divide_by 100 [get_pins cpu_clock_div_reg/Q]

set_property PACKAGE_PIN R11 [get_ports btn_reset]
set_property IOSTANDARD LVCMOS33 [get_ports btn_reset]
set_property PACKAGE_PIN K3 [get_ports led_heartbeat]
set_property PACKAGE_PIN M1 [get_ports led_pass]
set_property PACKAGE_PIN L1 [get_ports led_fault]
set_property IOSTANDARD LVCMOS33 [get_ports {led_heartbeat led_pass led_fault}]
set_property DRIVE 8 [get_ports {led_heartbeat led_pass led_fault}]
set_property SLEW SLOW [get_ports {led_heartbeat led_pass led_fault}]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.USR_ACCESS 0x41525031 [current_design]

# Only the asynchronous button's first synchronizer stage is cut.
# Related-clock reset transfer and all internal CPU paths remain timed.
set_false_path -from [get_ports btn_reset] -to [get_pins {button_sync_reg[0]/D}]
# Human-observed LEDs have no external receiving clock.
set_false_path -to [get_ports {led_heartbeat led_pass led_fault}]



