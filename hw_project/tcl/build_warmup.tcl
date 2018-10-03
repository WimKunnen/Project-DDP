set script_dir [file dirname [info script]]
set origin_dir "$script_dir/.."

# Create project
create_project project_hw $origin_dir/project_hw -part xc7z010clg400-1
set_property board_part digilentinc.com:zybo:part0:1.0 [current_project]

# Add source files
set files []
foreach file [glob $origin_dir/src/warmup/rtl/*] {
        lappend files [file normalize "$file"]
    }
add_files -norecurse -fileset [get_filesets sources_1] $files

# Add Simulation files
set files []
foreach file [glob $origin_dir/src/warmup/rtl_tb/*] {
        lappend files [file normalize "$file"]
    }
add_files -norecurse -fileset [get_filesets sim_1] $files

update_compile_order -fileset sim_1
update_compile_order -fileset sources_1