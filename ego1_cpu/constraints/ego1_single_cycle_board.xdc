# EGO1 XC7A35T-1CSG324C. Board supply and pins follow the EGO1 manual.
set_property PACKAGE_PIN P17 [get_ports clk_100mhz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100mhz]
create_clock -name board_clk -period 10.000 [get_ports clk_100mhz]

# General push button PB0 (S0 in the manual), pressed = high.
set_property PACKAGE_PIN R11 [get_ports btn_reset]
set_property IOSTANDARD LVCMOS33 [get_ports btn_reset]

# K3 is physically marked D16 on the user's board.
set_property PACKAGE_PIN K3 [get_ports led_pass]
set_property PACKAGE_PIN M1 [get_ports led_heartbeat]
set_property PACKAGE_PIN L1 [get_ports led_fault]
set_property IOSTANDARD LVCMOS33 [get_ports {led_pass led_heartbeat led_fault}]
set_property DRIVE 8 [get_ports {led_pass led_heartbeat led_fault}]
set_property SLEW SLOW [get_ports {led_pass led_heartbeat led_fault}]

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# The push button drives the MMCM's asynchronous reset. LEDs are human-viewed
# outputs, with no external sampling clock. Internal CPU paths stay timed.
set_false_path -from [get_ports btn_reset]
set_false_path -to [get_ports {led_pass led_heartbeat led_fault}]
