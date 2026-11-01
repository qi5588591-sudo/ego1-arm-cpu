set root [file normalize [file join [file dirname [info script]] ..]]
open_project [file join $root ego1_arm_pipeline_24.xpr]
set_property top tb_arm_pipeline [get_filesets sim_1]
launch_simulation -mode behavioral
set f [open [file join $root ego1_arm_pipeline_24.sim sim_1 behav xsim simulate.log] r]
set transcript [read $f];close $f
close_sim
set f [open [file join $root reports cpu_simulation.log] w];puts $f $transcript;close $f
close_project
if {[string first {ARM PIPELINE TESTS PASSED:} $transcript]<0 || [string first {Fatal:} $transcript]>=0} {
    error "ARM PIPELINE verification failed"
}
puts "ARM PIPELINE SIMULATION VERIFIED"
