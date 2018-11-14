set fileset   [current_fileset]
set topname   [get_property top [current_fileset]]

# puts $fileset
# puts $topname

if { $topname == "rsa_project_wrapper"} {
    puts "Constraints for rsa_project_wrapper"
    set_property PACKAGE_PIN M14      [get_ports {leds[0]}]
    set_property PACKAGE_PIN M15      [get_ports {leds[1]}]
    set_property PACKAGE_PIN G14      [get_ports {leds[2]}]
    set_property PACKAGE_PIN D18      [get_ports {leds[3]}]
    set_property IOSTANDARD  LVCMOS33 [get_ports {leds[0]}]
    set_property IOSTANDARD  LVCMOS33 [get_ports {leds[1]}]
    set_property IOSTANDARD  LVCMOS33 [get_ports {leds[2]}]
    set_property IOSTANDARD  LVCMOS33 [get_ports {leds[3]}]
} else {
    puts "Constraints for hw_evals"
    #Generate a clock with a period of 100MHz
    create_clock -period 10 -name clk_gen -add [get_ports clk]
    set_property PACKAGE_PIN L16      [get_ports clk]
    set_property PACKAGE_PIN R19      [get_ports data_ok]
    set_property PACKAGE_PIN P19      [get_ports resetn]
    set_property IOSTANDARD  LVCMOS33 [get_ports clk]
    set_property IOSTANDARD  LVCMOS33 [get_ports data_ok]
    set_property IOSTANDARD  LVCMOS33 [get_ports resetn]
}

#set_property PACKAGE_PIN M14      [get_ports {leds[0]}]
#set_property PACKAGE_PIN M15      [get_ports {leds[1]}]
#set_property PACKAGE_PIN G14      [get_ports {leds[2]}]
#set_property PACKAGE_PIN D18      [get_ports {leds[3]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {leds[0]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {leds[1]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {leds[2]}]
#set_property IOSTANDARD  LVCMOS33 [get_ports {leds[3]}]