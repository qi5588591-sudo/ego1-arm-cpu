set root [file normalize [file join [file dirname [info script]] ..]]
set_param general.maxThreads 2
if {![file exists [file join $root ego1_arm_pipeline_24.xpr]]} {
    source [file join $root scripts create_project.tcl]
}
source [file join $root scripts verify_simulation.tcl]
source [file join $root scripts verify_board.tcl]
source [file join $root scripts build_bitstream.tcl]
