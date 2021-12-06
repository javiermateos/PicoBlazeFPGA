#-------------------------------------------------------------------------------
# Constraints for pico_example in Zybo board
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# 1) TIMING CONSTRAINTS:

# Clock 125 MHz:
create_clock -name Clk -period 8.00 -waveform {0 4} [get_ports {Clk}]

# False path for I/O (normal in/out connected to human interfaces and
# treated as asynchronous, XReset also treated as asynchronous):
set_false_path -from [all_inputs]   -to [get_clocks *]
set_false_path -from [get_clocks *] -to [all_outputs]

#-------------------------------------------------------------------------------
# 2) PIN LOCATION AND I/O STANDARD CONSTRAINTS:

# Clock input:
set_property -dict "PACKAGE_PIN L16  IOSTANDARD LVCMOS33" [get_ports Clk]

# Reset input from JD2 pmod connector pin, apply internal pull-down:
set_property -dict "PACKAGE_PIN T15  IOSTANDARD LVCMOS33  PULLDOWN true" [get_ports XReset ]

# Push-Buttons 0 to 3:
set_property -dict "PACKAGE_PIN R18  IOSTANDARD LVCMOS33" [get_ports {Button[0]}]
set_property -dict "PACKAGE_PIN P16  IOSTANDARD LVCMOS33" [get_ports {Button[1]}]
set_property -dict "PACKAGE_PIN V16  IOSTANDARD LVCMOS33" [get_ports {Button[2]}]
set_property -dict "PACKAGE_PIN Y16  IOSTANDARD LVCMOS33" [get_ports {Button[3]}]
                                                                      
# Slide switches 0 to 3:
set_property -dict "PACKAGE_PIN G15  IOSTANDARD LVCMOS33" [get_ports {Switch[0]}]
set_property -dict "PACKAGE_PIN P15  IOSTANDARD LVCMOS33" [get_ports {Switch[1]}]
set_property -dict "PACKAGE_PIN W13  IOSTANDARD LVCMOS33" [get_ports {Switch[2]}]
set_property -dict "PACKAGE_PIN T16  IOSTANDARD LVCMOS33" [get_ports {Switch[3]}]

# Leds 0 to 3:
set_property -dict "PACKAGE_PIN M14  IOSTANDARD LVCMOS33" [get_ports {Led[0]}]
set_property -dict "PACKAGE_PIN M15  IOSTANDARD LVCMOS33" [get_ports {Led[1]}]
set_property -dict "PACKAGE_PIN G14  IOSTANDARD LVCMOS33" [get_ports {Led[2]}]
set_property -dict "PACKAGE_PIN D18  IOSTANDARD LVCMOS33" [get_ports {Led[3]}]

#-------------------------------------------------------------------------------
