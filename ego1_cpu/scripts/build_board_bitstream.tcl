set source_root [file normalize [file join [file dirname [info script]] ..]]
open_project [file join $source_root board_project ego1_single_cycle_board.xpr]
set_param general.maxThreads 2
launch_runs impl_1 -to_step write_bitstream -jobs 2
wait_on_run impl_1
set bit_file [file join $source_root board_project ego1_single_cycle_board.runs impl_1 ego1_single_cycle_board.bit]
if {![file exists $bit_file]} {
    error "Bitstream not produced. Implementation status: [get_property STATUS [get_runs impl_1]]"
}
open_run impl_1
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose \
    -file [file join $source_root validation board_timing_summary.rpt]
report_utilization -file [file join $source_root validation board_utilization.rpt]
report_drc -file [file join $source_root validation board_drc.rpt]
report_cdc -file [file join $source_root validation board_cdc.rpt]
set setup_path [get_timing_paths -delay_type max -max_paths 1]
set hold_path [get_timing_paths -delay_type min -max_paths 1]
if {[llength $setup_path] == 0 || [llength $hold_path] == 0} {
    error "Missing timed paths: do not claim timing closure."
}
set setup_slack [get_property SLACK $setup_path]
set hold_slack [get_property SLACK $hold_path]
puts "BOARD TIMING: setup slack=$setup_slack ns, hold slack=$hold_slack ns"
if {$setup_slack < 0 || $hold_slack < 0} {
    error "Board timing failed: bitstream is not ready for delivery."
}
set checked_bit [file join $source_root validation ego1_single_cycle_board_verified.bit]
file copy -force $bit_file $checked_bit
set report_handle [open [file join $source_root validation board_build_result.txt] w]
puts $report_handle "Part: xc7a35tcsg324-1"
puts $report_handle "Input clock: 100MHz; CPU clock: 10MHz"
puts $report_handle "Setup slack: $setup_slack ns"
puts $report_handle "Hold slack: $hold_slack ns"
puts $report_handle "Bitstream: $checked_bit"
puts $report_handle "Actual EGO1 hardware behavior is pending user observation."
close $report_handle
close_project
puts "BOARD BITSTREAM READY: $checked_bit"
