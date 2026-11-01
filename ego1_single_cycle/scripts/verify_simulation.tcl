set root [file normalize [file join [file dirname [info script]] ..]]
open_project [file join $root ego1_single_cycle.xpr]
foreach {top marker} {tb_single_cycle_cpu {SINGLE CYCLE TESTS PASSED:} tb_ego1_top {BOARD TESTS PASSED:}} {
    set_property top $top [get_filesets sim_1]
    launch_simulation -mode behavioral
    set log_path [file join $root ego1_single_cycle.sim sim_1 behav xsim simulate.log]
    set f [open $log_path r]; set transcript [read $f]; close $f
    close_sim
    set f [open [file join $root reports ${top}.log] w]; puts $f $transcript; close $f
    if {[string first $marker $transcript] < 0 || [string first {Fatal:} $transcript] >= 0} {
        error "Simulation failed: $top"
    }
    if {$top eq "tb_single_cycle_cpu" && [string first {FAULT TESTS PASSED:} $transcript] < 0} {
        error "Fault tests did not complete"
    }
}
set_property top tb_ego1_top [get_filesets sim_1]
close_project
puts "VERIFIED: CPU retirement, fault cases, board clock, reset and indicators"
