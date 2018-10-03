#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/esat/micas-data/software/xilinx_vivado_2016.2/SDK/2016.2/bin:/esat/micas-data/software/xilinx_vivado_2016.2/Vivado/2016.2/ids_lite/ISE/bin/lin64:/esat/micas-data/software/xilinx_vivado_2016.2/Vivado/2016.2/bin
else
  PATH=/esat/micas-data/software/xilinx_vivado_2016.2/SDK/2016.2/bin:/esat/micas-data/software/xilinx_vivado_2016.2/Vivado/2016.2/ids_lite/ISE/bin/lin64:/esat/micas-data/software/xilinx_vivado_2016.2/Vivado/2016.2/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=/esat/micas-data/software/xilinx_vivado_2016.2/Vivado/2016.2/ids_lite/ISE/lib/lin64
else
  LD_LIBRARY_PATH=/esat/micas-data/software/xilinx_vivado_2016.2/Vivado/2016.2/ids_lite/ISE/lib/lin64:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/users/start2017/r0634161/Desktop/DDP/package/hw_project/project_hw/project_hw.runs/synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log warmup1_verilog.vds -m64 -tempDir /tmp -mode batch -messageDb vivado.pb -notrace -source warmup1_verilog.tcl
