proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
set_msg_config -id {HDL-1065} -limit 10000
set_msg_config  -ruleid {1}  -id {Synth 8-327}  -new_severity {ERROR} 
set_msg_config  -ruleid {10}  -id {IP_Flow 19-2207}  -new_severity {INFO} 
set_msg_config  -ruleid {11}  -id {Vivado 12-3482}  -new_severity {INFO} 
set_msg_config  -ruleid {2}  -id {Synth 8-3352}  -new_severity {ERROR} 
set_msg_config  -ruleid {3}  -id {Synth 8-5559}  -new_severity {ERROR} 
set_msg_config  -ruleid {4}  -id {Timing 38-282}  -new_severity {WARNING} 
set_msg_config  -ruleid {5}  -id {BD 41-1629}  -new_severity {INFO} 
set_msg_config  -ruleid {6}  -id {BD 41-1343}  -new_severity {INFO} 
set_msg_config  -ruleid {7}  -id {BD_TCL-1000}  -new_severity {INFO} 
set_msg_config  -ruleid {8}  -id {IP_Flow 19-3899}  -new_severity {INFO} 
set_msg_config  -ruleid {9}  -id {IP_Flow 19-3153}  -new_severity {INFO} 

start_step init_design
set rc [catch {
  create_msg_db init_design.pb
  create_project -in_memory -part xc7z010clg400-1
  set_property board_part digilentinc.com:zybo:part0:1.0 [current_project]
  set_property design_mode GateLvl [current_fileset]
  set_param project.singleFileAddWarning.threshold 0
  set_property webtalk.parent_dir /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.cache/wt [current_project]
  set_property parent.project_path /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.xpr [current_project]
  set_property ip_repo_paths {
  /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.cache/ip
  /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_ipcores
  /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_ipcores
} [current_project]
  set_property ip_output_repo /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.cache/ip [current_project]
  set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
  add_files -quiet /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.runs/synth_1/rsa_project_wrapper.dcp
  read_xdc -ref rsa_project_axi_dma_0_0 -cells U0 /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.srcs/sources_1/bd/rsa_project/ip/rsa_project_axi_dma_0_0/rsa_project_axi_dma_0_0.xdc
  set_property processing_order EARLY [get_files /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.srcs/sources_1/bd/rsa_project/ip/rsa_project_axi_dma_0_0/rsa_project_axi_dma_0_0.xdc]
  read_xdc -prop_thru_buffers -ref rsa_project_rst_processing_system7_0_100M_0 -cells U0 /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.srcs/sources_1/bd/rsa_project/ip/rsa_project_rst_processing_system7_0_100M_0/rsa_project_rst_processing_system7_0_100M_0_board.xdc
  set_property processing_order EARLY [get_files /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.srcs/sources_1/bd/rsa_project/ip/rsa_project_rst_processing_system7_0_100M_0/rsa_project_rst_processing_system7_0_100M_0_board.xdc]
  read_xdc -ref rsa_project_rst_processing_system7_0_100M_0 -cells U0 /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.srcs/sources_1/bd/rsa_project/ip/rsa_project_rst_processing_system7_0_100M_0/rsa_project_rst_processing_system7_0_100M_0.xdc
  set_property processing_order EARLY [get_files /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.srcs/sources_1/bd/rsa_project/ip/rsa_project_rst_processing_system7_0_100M_0/rsa_project_rst_processing_system7_0_100M_0.xdc]
  read_xdc -ref rsa_project_processing_system7_0_0 -cells inst /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.srcs/sources_1/bd/rsa_project/ip/rsa_project_processing_system7_0_0/rsa_project_processing_system7_0_0.xdc
  set_property processing_order EARLY [get_files /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.srcs/sources_1/bd/rsa_project/ip/rsa_project_processing_system7_0_0/rsa_project_processing_system7_0_0.xdc]
  read_xdc -unmanaged /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/tcl/constraints.tcl
  read_xdc -ref rsa_project_axi_dma_0_0 -cells U0 /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.srcs/sources_1/bd/rsa_project/ip/rsa_project_axi_dma_0_0/rsa_project_axi_dma_0_0_clocks.xdc
  set_property processing_order LATE [get_files /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.srcs/sources_1/bd/rsa_project/ip/rsa_project_axi_dma_0_0/rsa_project_axi_dma_0_0_clocks.xdc]
  read_xdc -ref rsa_project_auto_us_0 -cells inst /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.srcs/sources_1/bd/rsa_project/ip/rsa_project_auto_us_0/rsa_project_auto_us_0_clocks.xdc
  set_property processing_order LATE [get_files /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.srcs/sources_1/bd/rsa_project/ip/rsa_project_auto_us_0/rsa_project_auto_us_0_clocks.xdc]
  read_xdc -ref rsa_project_auto_us_1 -cells inst /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.srcs/sources_1/bd/rsa_project/ip/rsa_project_auto_us_1/rsa_project_auto_us_1_clocks.xdc
  set_property processing_order LATE [get_files /users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.srcs/sources_1/bd/rsa_project/ip/rsa_project_auto_us_1/rsa_project_auto_us_1_clocks.xdc]
  link_design -top rsa_project_wrapper -part xc7z010clg400-1
  write_hwdef -file rsa_project_wrapper.hwdef
  close_msg_db -file init_design.pb
} RESULT]
if {$rc} {
  step_failed init_design
  return -code error $RESULT
} else {
  end_step init_design
}

start_step opt_design
set rc [catch {
  create_msg_db opt_design.pb
  opt_design 
  write_checkpoint -force rsa_project_wrapper_opt.dcp
  report_drc -file rsa_project_wrapper_drc_opted.rpt
  close_msg_db -file opt_design.pb
} RESULT]
if {$rc} {
  step_failed opt_design
  return -code error $RESULT
} else {
  end_step opt_design
}

start_step place_design
set rc [catch {
  create_msg_db place_design.pb
  implement_debug_core 
  place_design -directive ExtraTimingOpt
  write_checkpoint -force rsa_project_wrapper_placed.dcp
  report_io -file rsa_project_wrapper_io_placed.rpt
  report_utilization -file rsa_project_wrapper_utilization_placed.rpt -pb rsa_project_wrapper_utilization_placed.pb
  report_control_sets -verbose -file rsa_project_wrapper_control_sets_placed.rpt
  close_msg_db -file place_design.pb
} RESULT]
if {$rc} {
  step_failed place_design
  return -code error $RESULT
} else {
  end_step place_design
}

start_step phys_opt_design
set rc [catch {
  create_msg_db phys_opt_design.pb
  phys_opt_design -directive Explore
  write_checkpoint -force rsa_project_wrapper_physopt.dcp
  close_msg_db -file phys_opt_design.pb
} RESULT]
if {$rc} {
  step_failed phys_opt_design
  return -code error $RESULT
} else {
  end_step phys_opt_design
}

start_step route_design
set rc [catch {
  create_msg_db route_design.pb
  route_design -directive Explore
  write_checkpoint -force rsa_project_wrapper_routed.dcp
  report_drc -file rsa_project_wrapper_drc_routed.rpt -pb rsa_project_wrapper_drc_routed.pb
  report_timing_summary -warn_on_violation -max_paths 10 -file rsa_project_wrapper_timing_summary_routed.rpt -rpx rsa_project_wrapper_timing_summary_routed.rpx
  report_power -file rsa_project_wrapper_power_routed.rpt -pb rsa_project_wrapper_power_summary_routed.pb -rpx rsa_project_wrapper_power_routed.rpx
  report_route_status -file rsa_project_wrapper_route_status.rpt -pb rsa_project_wrapper_route_status.pb
  report_clock_utilization -file rsa_project_wrapper_clock_utilization_routed.rpt
  close_msg_db -file route_design.pb
} RESULT]
if {$rc} {
  step_failed route_design
  return -code error $RESULT
} else {
  end_step route_design
}

