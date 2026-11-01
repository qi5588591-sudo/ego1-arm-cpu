set source_root [file normalize [file join [file dirname [info script]] ..]]
foreach name {alu32.v regfile32.v program_counter.v loongarch_decoder.v single_cycle_cpu.v instruction_rom.v data_ram.v single_cycle_soc.v} {
    read_verilog [file join $source_root rtl $name]
}
synth_design -top single_cycle_soc -part xc7a35tcsg324-1 -mode out_of_context
report_utilization -file [file join $source_root validation single_cycle_utilization.rpt]
report_drc -file [file join $source_root validation single_cycle_synthesis_drc.rpt]
puts "SINGLE CYCLE RTL SYNTHESIS COMPLETED. Board timing is not evaluated in this stage."
