set root [file normalize [file join [file dirname [info script]] ..]]
set_param general.maxThreads 2
create_project -force ego1_arm_showcase $root -part xc7a35tcsg324-1
set_property target_language Verilog [current_project]
add_files [glob [file join $root rtl *.v]]
add_files [glob [file join $root rtl *.sv]]
add_files -fileset constrs_1 [file join $root constraints ego1_showcase.xdc]
add_files -fileset sim_1 [file join $root sim tb_showcase.sv]
set_property include_dirs [list [file join $root sim]] [get_filesets sim_1]
set_property top ego1_arm_showcase_top [get_filesets sources_1]
set_property top tb_showcase [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -mode behavioral
set f [open [file join $root ego1_arm_showcase.sim sim_1 behav xsim simulate.log] r]
set log [read $f];close $f
set f [open [file join $root reports simulation.log] w];puts $f $log;close $f
close_sim
if {[string first {SHOWCASE TESTS PASSED:} $log]<0 || [string first {Fatal:} $log]>=0} {error "Showcase simulation failed"}
launch_runs impl_1 -to_step write_bitstream -jobs 2
wait_on_run impl_1
if {[get_property STATUS [get_runs impl_1]] ne {write_bitstream Complete!}} {error "Build failed"}
open_run impl_1
report_timing_summary -delay_type min_max -report_unconstrained -file [file join $root reports timing.rpt]
check_timing -verbose -file [file join $root reports check_timing.rpt]
report_drc -file [file join $root reports drc.rpt]
report_cdc -file [file join $root reports cdc.rpt]
report_utilization -file [file join $root reports utilization.rpt]
set setup [get_timing_paths -delay_type max -max_paths 1]
set hold [get_timing_paths -delay_type min -max_paths 1]
if {[get_property SLACK $setup]<0 || [get_property SLACK $hold]<0} {error "Timing failed"}
set f [open [file join $root reports check_timing.rpt] r];set cov [read $f];close $f
foreach k {no_clock unconstrained_internal_endpoints generated_clocks} {
 if {![string match "*checking $k (0)*" $cov]} {error "Timing coverage $k"}
}
file copy -force [file join $root ego1_arm_showcase.runs impl_1 ego1_arm_showcase_top.bit] [file join $root download ego1_arm_showcase.bit]
puts "SHOWCASE BUILD PASSED setup=[get_property SLACK $setup] hold=[get_property SLACK $hold]"
close_project

