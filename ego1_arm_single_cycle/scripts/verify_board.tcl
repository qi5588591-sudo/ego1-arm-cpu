set root [file normalize [file join [file dirname [info script]] ..]]
open_project [file join $root ego1_arm_single_cycle.xpr]
set board_tb [file join $root sim tb_ego1_arm_top.sv]
if {[llength [get_files -quiet $board_tb]]==0} {add_files -fileset sim_1 -norecurse $board_tb}
set_property top tb_ego1_arm_top [get_filesets sim_1]
update_compile_order -fileset sim_1
launch_simulation -mode behavioral
set f [open [file join $root ego1_arm_single_cycle.sim sim_1 behav xsim simulate.log] r]
set transcript [read $f];close $f
close_sim
set f [open [file join $root reports board_simulation.log] w];puts $f $transcript;close $f
set_property top tb_arm_cpu [get_filesets sim_1]
close_project
if {[string first {BOARD TESTS PASSED:} $transcript]<0 || [string first {Fatal:} $transcript]>=0} {
    error "ARM board verification failed"
}
puts "ARM BOARD SIMULATION VERIFIED"
