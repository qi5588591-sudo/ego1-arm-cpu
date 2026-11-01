report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -file [file join $out timing_summary.rpt]
check_timing -verbose -file [file join $out check_timing.rpt]
set f [open [file join $out check_timing.rpt] r]
set timing_checks [read $f]
close $f
foreach item {no_clock unconstrained_internal_endpoints generated_clocks} {
    if {![string match "*checking $item (0)*" $timing_checks]} {
        error "Missing timing coverage: $item"
    }
}
report_drc -file [file join $out drc.rpt]
report_cdc -file [file join $out cdc.rpt]
report_clocks -file [file join $out clocks.rpt]
report_utilization -file [file join $out utilization.rpt]
set setup [get_property SLACK [get_timing_paths -delay_type max -max_paths 1]]
set hold [get_property SLACK [get_timing_paths -delay_type min -max_paths 1]]
if {$setup eq "" || $hold eq "" || $setup < 0 || $hold < 0} {
    error "Diagnostic timing failed: setup=$setup hold=$hold"
}
set cpu_cells [get_cells -quiet -hier -filter {NAME =~ u_soc/u_cpu/*}]
if {[llength $cpu_cells] < 100} { error "CPU hierarchy unexpectedly removed" }
set gate [get_cells u_cpu_clock]
if {[get_property REF_NAME $gate] ni {BUFGCE BUFGCTRL}} {error "CPU clock gate was removed"}
set ce_net [get_nets -of_objects [get_pins -quiet u_cpu_clock/CE0]]
if {[llength $ce_net] != 1 || [string first diag_clock_enable $ce_net] < 0} {error "Dynamic clock enable missing"}
set ce_setup_paths [get_timing_paths -to [get_pins u_cpu_clock/CE0] -delay_type max -max_paths 1]
set ce_hold_paths [get_timing_paths -to [get_pins u_cpu_clock/CE0] -delay_type min -max_paths 1]
if {[llength $ce_setup_paths] != 1 || [llength $ce_hold_paths] != 1} {
    error "Clock-enable setup/hold checks are not covered"
}
set ce_setup [get_property SLACK $ce_setup_paths]
set ce_hold [get_property SLACK $ce_hold_paths]
if {$ce_setup < 0 || $ce_hold < 0} {error "Clock-enable timing failed"}
report_timing -to [get_pins u_cpu_clock/CE0] -delay_type min_max -file [file join $out clock_enable_timing.rpt]
set c [get_clocks -of_objects [get_pins u_cpu_clock/O]]
if {[get_property PERIOD $c] != 1000} {error "CPU clock period is not 1000ns"}
set f [open [file join $out cdc.rpt] r]
set cdc [read $f]
close $f
if {[regexp -line {^Critical\s} $cdc]} {error "Critical CDC crossing"}

# New metadata marker and new output name; keep all previous bitstreams.
set_property BITSTREAM.CONFIG.USR_ACCESS 0x4D535431 [current_design]
set bitfile [file join $root download ego1_arm_pipeline_manual_start.bit]
write_bitstream -force $bitfile
write_checkpoint -force [file join $out manual_start_routed.dcp]
set f [open [file join $out build_result.txt] w]
puts $f "Manual-start diagnostic; CPU 1MHz; physical validation pending"
puts $f "Setup slack: $setup ns; hold slack: $hold ns"
puts $f "Clock-enable setup slack: $ce_setup ns; hold slack: $ce_hold ns"
puts $f "CPU leaf/hierarchical cells retained: [llength $cpu_cells]"
puts $f "Clock gate: [get_property REF_NAME $gate]; CPU period: [get_property PERIOD $c] ns"
puts $f "USR_ACCESS: 4D535431"
puts $f "Bitstream: $bitfile"
close $f
close_project
puts "MANUAL START BITSTREAM READY: $bitfile"
