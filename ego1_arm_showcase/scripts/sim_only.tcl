set root [file normalize [file join [file dirname [info script]] ..]]
set proj [file join $::env(TEMP) dsh_showcase_sim]
file delete -force $proj
create_project -force showcase_sim $proj -part xc7a35tcsg324-1
set_property target_language Verilog [current_project]
add_files [glob [file join $root rtl *.v]]
add_files [glob [file join $root rtl *.sv]]
add_files -fileset sim_1 [file join $root sim tb_showcase.sv]
set_property include_dirs [list [file join $root sim]] [get_filesets sim_1]
set_property top tb_showcase [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral
puts "SIM DONE"
