# Run with Vivado, or source from an existing Vivado Tcl Console.
# Existing project files are never replaced.
set source_root [file normalize [file join [file dirname [info script]] ..]]
set project_dir [file join $source_root project]
set project_file [file join $project_dir ego1_cpu.xpr]

if {[file exists $project_file]} {
    error "Project already exists: $project_file. Open that project instead."
}
if {[llength [get_projects -quiet]] != 0} {
    error "A project is already open. Close it before sourcing this script."
}

create_project ego1_cpu $project_dir -part xc7a35tcsg324-1
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

add_files -norecurse [list \
    [file join $source_root rtl alu32.v] \
    [file join $source_root rtl regfile32.v] \
    [file join $source_root rtl datapath_basics.v]]
add_files -fileset sim_1 -norecurse \
    [file join $source_root sim tb_datapath_basics.sv]
set_property top datapath_basics [get_filesets sources_1]
set_property top tb_datapath_basics [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "READY: $project_file"
