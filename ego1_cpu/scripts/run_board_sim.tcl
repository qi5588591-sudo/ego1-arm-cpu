set source_root [file normalize [file join [file dirname [info script]] ..]]
open_project [file join $source_root board_project ego1_single_cycle_board.xpr]
launch_simulation -mode behavioral
set transcript_file [file join $source_root board_project ego1_single_cycle_board.sim sim_1 behav xsim simulate.log]
set handle [open $transcript_file r]
set transcript [read $handle]
close $handle
close_sim
close_project
if {[string first "BOARD TESTS PASSED:" $transcript] < 0 ||
    [string first "Fatal:" $transcript] >= 0} {
    error "Board verification failed: $transcript_file"
}
puts "VERIFIED: board clocks, CPU completion, heartbeat, reset and fault indicators."
