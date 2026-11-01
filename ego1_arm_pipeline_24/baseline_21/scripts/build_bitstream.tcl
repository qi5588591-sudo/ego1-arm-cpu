set root [file normalize [file join [file dirname [info script]] ..]]
open_project [file join $root ego1_arm_pipeline.xpr]
set_param general.maxThreads 2
reset_runs synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 2
wait_on_run impl_1
if {[get_property STATUS [get_runs impl_1]] ne {write_bitstream Complete!}} {
    error "Build failed: [get_property STATUS [get_runs impl_1]]"
}
open_run impl_1
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -file [file join $root reports timing_summary.rpt]
report_drc -file [file join $root reports drc.rpt]
report_clocks -file [file join $root reports clocks.rpt]
report_cdc -file [file join $root reports cdc.rpt]
set f [open [file join $root reports cdc.rpt] r]
set cdc_text [read $f]; close $f
if {[regexp -line {^Critical\s} $cdc_text]} { error "Critical CDC crossing: see reports/cdc.rpt" }
report_utilization -file [file join $root reports utilization.rpt]
set setup [get_property SLACK [get_timing_paths -delay_type max -max_paths 1]]
set hold [get_property SLACK [get_timing_paths -delay_type min -max_paths 1]]
if {$setup eq "" || $hold eq "" || $setup < 0 || $hold < 0} { error "Timing failed: $setup / $hold" }
set src [file join $root ego1_arm_pipeline.runs impl_1 ego1_arm_pipeline_top.bit]
set dst [file join $root download ego1_arm_pipeline.bit]
file copy -force $src $dst
set f [open [file join $root reports build_result.txt] w]
puts $f "Part: xc7a35tcsg324-1; board 100MHz; CPU 1MHz"
puts $f "Setup slack: $setup ns; hold slack: $hold ns"
puts $f "USR_ACCESS: 41525031; compressed bitstream: $dst"
puts $f "Physical board behavior: pending user verification"
close $f
close_project
puts "BITSTREAM READY: $dst"


