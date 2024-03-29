connect -url tcp:127.0.0.1:3121
source /users/start2016/r0629332/Project-DDP/actual_project/sw_project/project_sw/hw_platform/ps7_init.tcl
targets -set -filter {name =~"APU" && jtag_cable_name =~ "Digilent Zybo 210279785167A"} -index 0
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Digilent Zybo 210279785167A" && level==0} -index 1
fpga -file /users/start2016/r0629332/Project-DDP/actual_project/sw_project/project_sw/hw_platform/rsa_project_wrapper.bit
targets -set -filter {name =~"APU" && jtag_cable_name =~ "Digilent Zybo 210279785167A"} -index 0
loadhw /users/start2016/r0629332/Project-DDP/actual_project/sw_project/project_sw/hw_platform/system.hdf
targets -set -filter {name =~"APU" && jtag_cable_name =~ "Digilent Zybo 210279785167A"} -index 0
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Zybo 210279785167A"} -index 0
dow /users/start2016/r0629332/Project-DDP/actual_project/sw_project/project_sw/sw_design/Debug/sw_design.elf
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Zybo 210279785167A"} -index 0
con
