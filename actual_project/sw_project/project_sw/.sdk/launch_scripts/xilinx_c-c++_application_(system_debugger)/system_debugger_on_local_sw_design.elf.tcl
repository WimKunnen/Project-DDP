connect -url tcp:127.0.0.1:3121
source /users/start2017/r0634161/Git/Project-DDP/actual_project/sw_project/project_sw/hw_platform/ps7_init.tcl
targets -set -filter {name =~"APU" && jtag_cable_name =~ "Digilent Zybo 210279785167A"} -index 0
loadhw /users/start2017/r0634161/Git/Project-DDP/actual_project/sw_project/project_sw/hw_platform/system.hdf
targets -set -filter {name =~"APU" && jtag_cable_name =~ "Digilent Zybo 210279785167A"} -index 0
stop
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Zybo 210279785167A"} -index 0
rst -processor
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Zybo 210279785167A"} -index 0
dow /users/start2017/r0634161/Git/Project-DDP/actual_project/sw_project/project_sw/sw_design/Debug/sw_design.elf
targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent Zybo 210279785167A"} -index 0
con
