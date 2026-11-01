set root [file normalize [file join [file dirname [info script]] ..]]
if {[file exists [file join $root ego1_single_cycle.xpr]]} { error "Project already exists" }
create_project ego1_single_cycle $root -part xc7a35tcsg324-1
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
add_files -norecurse [glob [file join $root rtl *.v]]
add_files -fileset constrs_1 -norecurse [file join $root constraints ego1.xdc]
add_files -fileset sim_1 -norecurse [glob [file join $root sim *.sv]]
add_files -fileset sim_1 -norecurse [file join $root sim single_cycle_expected.vh]
set_property include_dirs [list [file join $root sim]] [get_filesets sim_1]
set_property top ego1_top [get_filesets sources_1]
set_property top tb_ego1_top [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
close_project
puts "PROJECT CREATED: [file join $root ego1_single_cycle.xpr]"
