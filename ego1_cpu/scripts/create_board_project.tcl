set source_root [file normalize [file join [file dirname [info script]] ..]]
set project_dir [file join $source_root board_project]
set project_file [file join $project_dir ego1_single_cycle_board.xpr]
if {[file exists $project_file]} { error "Project already exists: $project_file" }
if {[llength [get_projects -quiet]] != 0} { error "Close the open project first." }
create_project ego1_single_cycle_board $project_dir -part xc7a35tcsg324-1
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]
set rtl_files {}
foreach name {alu32.v regfile32.v program_counter.v loongarch_decoder.v single_cycle_cpu.v instruction_rom.v data_ram.v single_cycle_soc.v ego1_clock.v ego1_single_cycle_board.v} {
    lappend rtl_files [file join $source_root rtl $name]
}
add_files -norecurse $rtl_files
add_files -fileset constrs_1 -norecurse [file join $source_root constraints ego1_single_cycle_board.xdc]
add_files -fileset sim_1 -norecurse [file join $source_root sim tb_ego1_single_cycle_board.sv]
set_property top ego1_single_cycle_board [get_filesets sources_1]
set_property top tb_ego1_single_cycle_board [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "READY: $project_file"
