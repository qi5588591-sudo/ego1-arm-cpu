set root [file normalize [file join [file dirname [info script]] ..]]
set out [file join $root diagnostics manual_start_final]
file mkdir $out
if {[file exists [file join $out project ego1_arm_pipeline_manual_start.xpr]]} {
    error "Diagnostic project already exists; keep it or select a new build directory."
}
set_param general.maxThreads 2
create_project ego1_arm_pipeline_manual_start [file join $out project] -part xc7a35tcsg324-1
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
add_files -norecurse [concat [glob [file join $root rtl *.v]] [glob [file join $root rtl *.sv]]]
set f [open [file join $root constraints ego1.xdc] r]
set xdc [read $f]
close $f
# Clock the gate input as well as its output, so CE setup/hold are checked.
set xdc [string map [list {[get_pins u_cpu_clock/O]} {[get_pins cpu_clock_div_reg/Q]}] $xdc]
set f [open [file join $out manual_start.xdc] w]
puts $f $xdc
close $f
add_files -fileset constrs_1 -norecurse [file join $out manual_start.xdc]
add_files -fileset sim_1 -norecurse [file join $root sim tb_ego1_arm_pipeline_manual_start.sv]
set_property top ego1_arm_pipeline_top [get_filesets sources_1]
set_property top tb_ego1_arm_pipeline_manual_start [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
launch_simulation -mode behavioral
set logpath [file join $out project ego1_arm_pipeline_manual_start.sim sim_1 behav xsim simulate.log]
set f [open $logpath r]
set simulation [read $f]
close $f
close_sim
set f [open [file join $out simulation.log] w]
puts $f $simulation
close $f
if {[string first {MANUAL START TESTS PASSED:} $simulation] < 0 ||
    [string first {Fatal:} $simulation] >= 0} {
    error "Manual-start simulation failed."
}
puts "MANUAL START SIMULATION VERIFIED"

launch_runs impl_1 -to_step route_design -jobs 2
wait_on_run impl_1
if {[get_property STATUS [get_runs impl_1]] ne {route_design Complete!}} {
    error "Diagnostic implementation failed: [get_property STATUS [get_runs impl_1]]"
}
open_run impl_1
source [file join $root scripts finish_manual_start.tcl]
