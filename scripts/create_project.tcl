# ============================================================
# 自动定位脚本所在目录
# ============================================================
set script_dir [file dirname [file normalize [info script]]]

# 项目根目录 = scripts/ 的上一级
set project_root [file normalize [file join $script_dir ".."]]

# build 目录路径
set build_dir [file join $project_root "build"]

# ============================================================
# 每次运行都清空 build 目录
# ============================================================
if {[file exists $build_dir]} {
    file delete -force $build_dir
}
file mkdir $build_dir

puts "Project root = $project_root"
puts "Build dir    = $build_dir"

# ============================================================
# create new Vivado project
# ============================================================
set project_name "my_project"
set project_part "xc7a100tftg256-2"

create_project $project_name $build_dir -part $project_part -force

# ============================================================
# register IP repository and refresh IP Catalog
# ============================================================
set local_ip_repo [file join $project_root "ip_core"]
if {[file isdirectory $local_ip_repo]} {
    set_property ip_repo_paths [list $local_ip_repo] [current_project]
    update_ip_catalog
    puts "Local IP repository registered: $local_ip_repo"
    puts "IP Catalog updated!"
} else {
    puts "Local IP repository not found, skip: $local_ip_repo"
}

# ============================================================
# use src/create_bd.tcl to create Block Design
# ============================================================
source [file join $project_root "src" "create_bd.tcl"]
puts "Project '$project_name' created with block design!"

# ============================================================
# Generate Output Products for Block Design
# ============================================================
set bd_path [get_files *.bd]
if {[llength $bd_path] > 0} {
    set bd_file [lindex $bd_path 0]
    puts "Generating output products for Block Design..."
    generate_target all [get_files $bd_file]
    puts "Output products generated successfully!"
} else {
    puts "No Block Design files found"
}

# ============================================================
# auto scan and add constraint files from the constraint directory
# ============================================================
set constraint_dir [file join $project_root "constraint"]
if {[file isdirectory $constraint_dir]} {
    set constraint_files [glob -nocomplain [file join $constraint_dir "*.xdc"]]
    if {[llength $constraint_files] > 0} {
        foreach constraint_file $constraint_files {
            add_files -fileset constrs_1 $constraint_file
            set_property file_type XDC [get_files $constraint_file]
            puts "Added constraint file: [file tail $constraint_file]"
        }
        puts "Total constraint files added: [llength $constraint_files]"
    } else {
        puts "No XDC files found in $constraint_dir"
    }
} else {
    puts "Constraint directory not found: $constraint_dir"
}

# ============================================================
# Generate HDL wrapper for Block Design
# ============================================================
set bd_path [get_files *.bd]
if {[llength $bd_path] > 0} {
    set bd_file [lindex $bd_path 0]
    puts "Generating HDL wrapper for: $bd_file"
    make_wrapper -files [get_files $bd_file] -top
    
    # Search for wrapper files in the generated directory
    set project_gen_dir [file normalize [file join [get_property DIRECTORY [current_project]] "${project_name}.gen"]]
    set wrapper_file [glob -nocomplain [file join $project_gen_dir "sources_1" "bd" "*" "hdl" "*wrapper.v"]]
    
    if {[llength $wrapper_file] > 0} {
        set wrapper_path [lindex $wrapper_file 0]
        add_files $wrapper_path
        set wrapper_name [file rootname [file tail $wrapper_path]]
        set_property top $wrapper_name [current_fileset]
        puts "Added and set top-level module: $wrapper_name"
    } else {
        puts "ERROR: Wrapper file not found in: $project_gen_dir"
    }
} else {
    puts "No Block Design files found"
}

# ============================================================
# Synthesis
# ============================================================
puts "Starting synthesis..."
launch_runs synth_1 -jobs 16
wait_on_run synth_1
puts "Synthesis completed!"

# ============================================================
# Implementation
# ============================================================
puts "Starting implementation..."
launch_runs impl_1 -jobs 16
wait_on_run impl_1
puts "Implementation completed!"

# ============================================================
# Generate Bitstream
# ============================================================
puts "Generating bitstream..."
launch_runs impl_1 -to_step write_bitstream -jobs 16
wait_on_run impl_1
puts "Bitstream generation completed!"

# ============================================================
# Save project
# ============================================================
save_project [current_project]
puts "Project saved!"

# ============================================================
# Report file locations
# ============================================================
puts ""
puts "=== Project build finished ==="
puts "Project location    : $build_dir"
puts "Bitstream file      : $build_dir/$project_name.runs/impl_1/$project_name.bit"
puts "Timing report       : $build_dir/$project_name.runs/impl_1/runme.log"
puts ""
puts "To program FPGA, use the .bit file with Vivado Hardware Manager or external programmer."

exit