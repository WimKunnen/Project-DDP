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

HD_PWD='/users/start2017/r0634161/Git/Project-DDP/actual_project/hw_project/project_hw/project_hw.runs/impl_2'
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

# pre-commands:
/bin/touch .init_design.begin.rst
EAStep vivado -log hweval_adder.vdi -applog -m64 -tempDir /tmp -messageDb vivado.pb -mode batch -source hweval_adder.tcl -notrace


