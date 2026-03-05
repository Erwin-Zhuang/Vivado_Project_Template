# ============================================================
# Constraint file for template_ip block design
# ============================================================

# Clock pin (N14) - CMOS3v3 - 40MHz
set_property PACKAGE_PIN N14 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PERIOD 25.000 [get_clocks clk]


# Reset pin (T7) - 3.3V
set_property PACKAGE_PIN T7 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# OUTPUT pin (P8) - 3.3V
set_property PACKAGE_PIN P8 [get_ports dout]
set_property IOSTANDARD LVCMOS33 [get_ports dout]

