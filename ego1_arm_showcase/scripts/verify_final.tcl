set root [file normalize [file join [file dirname [info script]] ..]]
set_param general.maxThreads 2
open_project [file join $root ego1_arm_showcase.xpr]
launch_simulation -mode behavioral
set f [open [file join $root ego1_arm_showcase.sim sim_1 behav xsim simulate.log] r]
set log [read $f];close $f
close_sim
set f [open [file join $root reports simulation.log] w];puts $f $log;close $f
if {[string first {SHOWCASE TESTS PASSED:} $log]<0 || [string first {Fatal:} $log]>=0} {error "Final display verification failed"}
open_run impl_1
set first_sync [get_pins -hier -filter {NAME =~ *u_button/sync_reg[0]/D}]
puts "FIRST SYNCHRONIZER PINS = $first_sync"
if {[llength $first_sync]!=5} {error "Expected exactly five asynchronous input cuts"}
set f [open [file join $root reports cdc.rpt] r];set cdc [read $f];close $f
if {[regexp {CDC-[0-9]+\s+Critical} $cdc]} {error "Critical CDC crossing"}
close_project
puts "SHOWCASE FINAL CHECKS PASSED"
