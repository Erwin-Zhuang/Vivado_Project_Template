# ============================================================
# Vivado Custom IP Batch Packaging Script
# ============================================================

# -------------------------------
# Function: Collect HDL files recursively
# -------------------------------
proc collect_hdl_files {dir patterns} {
    set files {}
    foreach item [glob -nocomplain -directory $dir *] {
        if {[file isdirectory $item]} {
            set sub_files [collect_hdl_files $item $patterns]
            if {[llength $sub_files] > 0} {
                set files [concat $files $sub_files]
            }
        } else {
            set name [file tail $item]
            foreach p $patterns {
                if {[string match $p $name]} {
                    lappend files $item
                    break
                }
            }
        }
    }
    return $files
}

# -------------------------------
# Function: Package a single IP
# -------------------------------
proc package_one_ip {ip_dir ip_name project_part} {
    set src_dir [file join $ip_dir "src"]
    if {![file isdirectory $src_dir]} {
        return -code error "Missing src directory: $src_dir"
    }

    set hdl_patterns [list "*.v" "*.sv" "*.vh" "*.vhd" "*.vhdl"]
    set hdl_files [collect_hdl_files $src_dir $hdl_patterns]
    if {[llength $hdl_files] == 0} {
        return -code error "No HDL files found in: $src_dir"
    }

    set temp_proj [file join $ip_dir "_tmp_pkg_proj"]
    if {[file exists $temp_proj]} {
        file delete -force $temp_proj
    }

    create_project "${ip_name}_pkg" $temp_proj -part $project_part -force
    add_files $hdl_files
    update_compile_order -fileset sources_1

    # 默认 top module/entity == 文件夹名
    set_property top $ip_name [current_fileset]

    ipx::package_project -root_dir $ip_dir -vendor user.org -library user -taxonomy /UserIP -force
    set core [ipx::current_core]
    set_property name $ip_name $core
    set_property display_name $ip_name $core
    set_property version 1.0 $core
    ipx::save_core $core
    ipx::check_integrity -quiet $core

    close_project

    if {[file exists $temp_proj]} {
        file delete -force $temp_proj
    }
}

# ============================================================
# Main Script
# ============================================================

# 脚本目录
set script_dir [file dirname [file normalize [info script]]]
set project_root [file normalize [file join $script_dir ".."]]
set ip_root [file join $project_root "ip_core"]

# FPGA part 默认值
set project_part "xc7a100tftg256-2"

# -------------------------------
# Step 0: Clean previously packaged IPs
# -------------------------------
if {![file isdirectory $ip_root]} {
    puts "ERROR: ip_core directory not found: $ip_root"
    exit 1
}

puts "Cleaning previously packaged IPs under $ip_root ..."
foreach ip_dir [glob -nocomplain -directory $ip_root *] {
    if {[file isdirectory $ip_dir]} {
        # 删除旧 component.xml
        set comp_file [file join $ip_dir "component.xml"]
        if {[file exists $comp_file]} {
            file delete -force $comp_file
            puts "  Deleted $comp_file"
        }

        # 删除旧临时工程
        set tmp_proj [file join $ip_dir "_tmp_pkg_proj"]
        if {[file exists $tmp_proj]} {
            file delete -force $tmp_proj
            puts "  Deleted temp project $tmp_proj"
        }
    }
}
puts "Clean done."

# -------------------------------
# Step 1: Find IP directories
# -------------------------------
set ip_dirs {}
foreach d [glob -nocomplain -directory $ip_root *] {
    if {[file isdirectory $d]} {
        lappend ip_dirs $d
    }
}

if {[llength $ip_dirs] == 0} {
    puts "No IP directories found under: $ip_root"
    exit 0
}

# -------------------------------
# Step 2: Package all IPs
# -------------------------------
set success_list {}
set failed_list {}

puts "Found [llength $ip_dirs] IP candidate(s) under: $ip_root"
foreach ip_dir $ip_dirs {
    set ip_name [file tail $ip_dir]
    puts ""
    puts "=== Packaging IP: $ip_name ==="
    if {[catch {package_one_ip $ip_dir $ip_name $project_part} err]} {
        puts "FAILED: $ip_name"
        puts "Reason: $err"
        lappend failed_list $ip_name
    } else {
        puts "OK: $ip_name"
        lappend success_list $ip_name
    }
}

# -------------------------------
# Step 3: Summary
# -------------------------------
puts ""
puts "================ Summary ================"
puts "Success: [llength $success_list]"
foreach ip $success_list { puts "  - $ip" }
puts "Failed : [llength $failed_list]"
foreach ip $failed_list { puts "  - $ip" }

if {[llength $failed_list] > 0} {
    exit 1
}
exit 0