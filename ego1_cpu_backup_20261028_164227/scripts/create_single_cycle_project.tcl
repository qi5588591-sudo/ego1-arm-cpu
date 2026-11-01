set source_root [file normalize [file join [file dirname [info script]] ..]]
set project_dir [file join $source_root single_cycle_project]
set project_file [file join $project_dir ego1_single_cycle.xpr]
if {[file exists $project_file]} {
    error "Project exists: $project_file. Open it instead of replacing it."
}
if {[llength [get_projects -quiet]] != 0} {
    error "Close the current project before creating this project."
}
create_project ego1_single_cycle $project_dir -part xc7a35tcsg324-1
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set rtl_files {}
foreach name {alu32.v regfile32.v program_counter.v loongarch_decoder.v single_cycle_cpu.v instruction_rom.v data_ram.v single_cycle_soc.v} {
    lappend rtl_files [file join $source_root rtl $name]
}
add_files -norecurse $rtl_files
add_files -fileset sim_1 -norecurse [list \
    [file join $source_root sim tb_single_cycle_cpu.sv] \
    [file join $source_root sim cpu_fault_tests.sv] \
    [file join $source_root sim single_cycle_expected.vh]]
set_property include_dirs [list [file join $source_root sim]] [get_filesets sim_1]
set_property top single_cycle_soc [get_filesets sources_1]
set_property top tb_single_cycle_cpu [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "READY: $project_file"
