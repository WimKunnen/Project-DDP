#!/bin/bash -f
xv_path="/esat/micas-data/software/xilinx_vivado_2016.2/Vivado/2016.2"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto 1e1f8037e01b436e9215976185af9138 -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot tb_warmup2_mpadder_behav xil_defaultlib.tb_warmup2_mpadder xil_defaultlib.glbl -log elaborate.log
