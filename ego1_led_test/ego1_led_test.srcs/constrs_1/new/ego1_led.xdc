# 100MHz板载时钟
set_property PACKAGE_PIN P17 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -name sys_clk -period 10.000 [get_ports clk]

# LED：D1_0，高电平点亮
set_property PACKAGE_PIN K3 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]