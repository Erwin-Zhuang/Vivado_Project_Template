# ============================================================
# create blank Block Design
# ============================================================

# set block design name
set bd_name "block_design"

# create block design
create_bd_design $bd_name

# ============================================================
# init: check and list all available custom IPs
# ============================================================
set script_dir [file dirname [file normalize [info script]]]
set project_root [file normalize [file join $script_dir ".."]]
set ip_core_dir [file join $project_root "ip_core"]

if {[file isdirectory $ip_core_dir]} {
    puts "Available custom IPs:"
    foreach ip_dir [glob -nocomplain -directory $ip_core_dir *] {
        if {[file isdirectory $ip_dir]} {
            set ip_name [file tail $ip_dir]
            puts "  - $ip_name (VLNV: user.org:user:${ip_name}:1.0)"
        }
    }
} else {
    puts "ip_core directory not found: $ip_core_dir"
}

# ============================================================
# Block Design 
# ============================================================

# example：add template_ip instance :
create_bd_cell -type ip -vlnv user.org:user:template_ip:1.0 template_ip_1

# ============================================================
# Create external ports and connect to IP pins
# ============================================================

# Create external CLK port
set clk_port [create_bd_port -name clk -type CLK -dir I]
# Create external RST port
set rst_port [create_bd_port -name rst -type RST -dir I]
# Create external OUTPUT port
set dout_port [create_bd_port -name dout -dir O]

# Connect CLK port to template_ip_1
connect_bd_net [get_bd_pins template_ip_1/clk] [get_bd_ports clk]
# Connect RST port to template_ip_1
connect_bd_net [get_bd_pins template_ip_1/rst] [get_bd_ports rst]
# Connect OUTPUT port
connect_bd_net [get_bd_pins template_ip_1/dout] [get_bd_ports dout]


# ============================================================
# save block design
# ============================================================
save_bd_design

