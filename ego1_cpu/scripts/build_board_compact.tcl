# Reuse the fully routed, timing-checked design. No hardware connection is made.
set source_root [file normalize [file join [file dirname [info script]] ..]]
open_checkpoint [file join $source_root board_project ego1_single_cycle_board.runs impl_1 ego1_single_cycle_board_routed.dcp]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.USR_ACCESS 0x43505531 [current_design]
set bit_file [file join $source_root validation ego1_single_cycle_board_cpu1_compact.bit]
write_bitstream -force $bit_file
puts "COMPACT_BIT_READY: $bit_file ([file size $bit_file] bytes), USR_ACCESS=43505531"
