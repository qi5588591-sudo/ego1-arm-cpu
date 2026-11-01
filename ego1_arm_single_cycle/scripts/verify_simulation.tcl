set root [file normalize [file join [file dirname [info script]] ..]]
open_project [file join $root ego1_arm_single_cycle.xpr]
set_property top tb_arm_cpu [get_filesets sim_1]
launch_simulation -mode behavioral
set f [open [file join $root ego1_arm_single_cycle.sim sim_1 behav xsim simulate.log] r]
set transcript [read $f];close $f
close_sim
set f [open [file join $root reports cpu_simulation.log] w];puts $f $transcript;close $f
close_project
if {[string first {ARM CPU TESTS PASSED:} $transcript]<0 || [string first {Fatal:} $transcript]>=0} {
    error "ARM CPU verification failed: reports/cpu_simulation.log"
}
puts "ARM CPU SIMULATION VERIFIED"
