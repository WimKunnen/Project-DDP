#############
# IP Settings
#############

set design command_interface

set projdir ./project_ipcores/accelerator_interface

set script_dir [file dirname [info script]]
set origin_dir "$script_dir/.."

# FPGA device
set partname "xc7z010clg400-1"

# Board part
set boardpart "digilentinc.com:zybo:part0:1.0"

# set hdl_files [list $root/rtl/]
set hdl_files [list \
    [file normalize $origin_dir/src/ipcore_interface/command_interface.v         ] \
    [file normalize $origin_dir/src/ipcore_interface/command_interface_S00_AXI.v ] ]

# set hdl_sim    [list \
#     [file normalize $root/rtl/tb_wrapper.v                       ] \
#     ]

set ip_files []

set constraints_files []

# Other variables
set clk_s00_axi "s00_axi_aclk"

###########################
# Create Managed IP Project
###########################

create_project -force $design $projdir -part $partname 
set_property target_language Verilog [current_project]
set_property source_mgmt_mode None [current_project]

if {$boardpart != ""} {
set_property "board_part" $boardpart [current_project]
}

##########################################
# Create filesets and add files to project
##########################################

#HDL
if {[string equal [get_filesets -quiet sources_1] ""]} {
    create_fileset -srcset sources_1
}
add_files -norecurse -fileset [get_filesets sources_1] $hdl_files


#HDL FOR SIMULATION
# if {[string equal [get_filesets -quiet sim_1] ""]} {
#     create_fileset -srcset sim_1
# }
# add_files -norecurse -fileset [get_filesets sim_1] $hdl_sim


#CONSTRAINTS
if {[string equal [get_filesets -quiet constraints_1] ""]} {
  create_fileset -constrset constraints_1
}
if {[llength $constraints_files] != 0} {
    add_files -norecurse -fileset [get_filesets constraints_1] $constraints_files
}

#ADDING IP
if {[llength $ip_files] != 0} {
    
    #Add to fileset
    add_files -norecurse -fileset [get_filesets sources_1] $ip_files
   
    #RERUN/UPGRADE IP
    upgrade_ip [get_ips]
}

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

##########################################
# Synthesize (Optional, checks for sanity)
##########################################

#set_property top $design [current_fileset]
#launch_runs synth_1 -jobs 2
#wait_on_run synth_1


#########
# Package
#########

ipx::package_project -root_dir $projdir
# ipx::package_project -import_files -force -root_dir $projdir
ipx::associate_bus_interfaces -busif s00_axi -clock $clk_s00_axi [ipx::current_core]
ipx::remove_memory_map {s00_axi} [ipx::current_core]
ipx::add_memory_map {s00_axi} [ipx::current_core]
set_property slave_memory_map_ref {s00_axi} [ipx::get_bus_interfaces s00_axi -of_objects [ipx::current_core]]
ipx::add_address_block {axi_lite} [ipx::get_memory_maps s00_axi -of_objects [ipx::current_core]]
set_property range {65536} [ipx::get_address_blocks axi_lite -of_objects \
    [ipx::get_memory_maps s00_axi -of_objects [ipx::current_core]]]

set_property vendor              {cosic}                        [ipx::current_core]
set_property library             {fturan}                       [ipx::current_core]
set_property taxonomy            {{/AXI_Infrastructure}}        [ipx::current_core]
set_property vendor_display_name {COSIC}                        [ipx::current_core]
set_property company_url         {www.esat.kuleuven.be/cosic/}  [ipx::current_core]
set_property supported_families  { \
                     {virtex7}    {Production} \
                     {qvirtex7}   {Production} \
                     {kintex7}    {Production} \
                     {kintex7l}   {Production} \
                     {qkintex7}   {Production} \
                     {qkintex7l}  {Production} \
                     {artix7}     {Production} \
                     {artix7l}    {Production} \
                     {aartix7}    {Production} \
                     {qartix7}    {Production} \
                     {zynq}       {Production} \
                     {qzynq}      {Production} \
                     {azynq}      {Production} \
                     }   [ipx::current_core]

############################
# Save and Write ZIP archive
############################

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::check_integrity -quiet [ipx::current_core]
ipx::archive_core [concat $projdir/$design.zip] [ipx::current_core]



set_msg_config -suppress -id {IP_Flow 19-731}