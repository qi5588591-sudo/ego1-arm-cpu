set source_root [file normalize [file join [file dirname [info script]] ..]]
open_project [file join $source_root single_cycle_project ego1_single_cycle.xpr]
launch_simulation -mode behavioral
set transcript_file [file join $source_root single_cycle_project ego1_single_cycle.sim sim_1 behav xsim simulate.log]
set transcript_handle [open $transcript_file r]
set transcript [read $transcript_handle]
close $transcript_handle
close_sim
close_project
if {[string first "SINGLE CYCLE TESTS PASSED:" $transcript] < 0 ||
    [string first "FAULT TESTS PASSED:" $transcript] < 0 ||
    [string first "Fatal:" $transcript] >= 0} {
    error "Verification failed. Read $transcript_file for the first failing check."
}
puts "VERIFIED: main program and all fault cases passed."
