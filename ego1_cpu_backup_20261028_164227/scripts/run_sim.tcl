set source_root [file normalize [file join [file dirname [info script]] ..]]
open_project [file join $source_root project ego1_cpu.xpr]
launch_simulation -mode behavioral
close_sim
close_project
