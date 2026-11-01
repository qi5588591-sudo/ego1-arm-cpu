set root [file normalize [file join [file dirname [info script]] ..]]
if {[file exists [file join $root ego1_arm_pipeline_24.xpr]]} {error "Project exists"}
create_project ego1_arm_pipeline_24 $root -part xc7a35tcsg324-1
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
add_files -norecurse [concat [glob [file join $root rtl *.v]] [glob [file join $root rtl *.sv]]]
add_files -fileset constrs_1 -norecurse [file join $root constraints ego1.xdc]
add_files -fileset sim_1 -norecurse [concat [glob [file join $root sim *.sv]] [glob [file join $root sim *.v]] [glob [file join $root sim *.vh]]]
set_property include_dirs [list [file join $root sim]] [get_filesets sim_1]
set_property top ego1_arm_pipeline_top [get_filesets sources_1]
set_property top tb_arm_pipeline [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
close_project
puts "ARM PIPELINE PROJECT CREATED"
