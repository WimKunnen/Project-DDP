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

set_msg_config -id {Common 17-41} -limit 10000000
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

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  open_checkpoint rsa_project_wrapper_routed.dcp
  set_property webtalk.parent_dir /users/start2016/r0629332/Project-DDP/actual_project/hw_project/project_hw/project_hw.cache/wt [current_project]
  catch { write_mem_info -force rsa_project_wrapper.mmi }
  write_bitstream -force rsa_project_wrapper.bit 
  catch { write_sysdef -hwdef rsa_project_wrapper.hwdef -bitfile rsa_project_wrapper.bit -meminfo rsa_project_wrapper.mmi -file rsa_project_wrapper.sysdef }
  catch {write_debug_probes -quiet -force debug_nets}
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

