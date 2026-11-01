set root [file normalize [file join [file dirname [info script]] ..]]
set_param general.maxThreads 2
source [file join $root scripts verify_simulation.tcl]
open_project [file join $root ego1_arm_pipeline_24.xpr]
open_run impl_1
check_timing -verbose -file [file join $root reports check_timing.rpt]
set f [open [file join $root reports check_timing.rpt] r]
set checks [read $f]; close $f
foreach item {no_clock unconstrained_internal_endpoints generated_clocks} {
    if {![string match "*checking $item (0)*" $checks]} {error "Missing timing coverage: $item"}
}
report_utilization -hierarchical -file [file join $root reports utilization_hierarchical.rpt]
if {[llength [get_cells -quiet -hier -filter {NAME =~ u_soc/u_cpu/u_mdu/*}]] < 50} {
    error "MDU was unexpectedly removed by synthesis"
}
close_project
puts "24-INSTRUCTION FINAL CHECKS PASSED"
