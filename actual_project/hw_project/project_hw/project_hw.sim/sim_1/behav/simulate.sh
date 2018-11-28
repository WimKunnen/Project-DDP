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
ExecStep $xv_path/bin/xsim tb_rsa_wrapper_behav -key {Behavioral:sim_1:Functional:tb_rsa_wrapper} -tclbatch tb_rsa_wrapper.tcl -log simulate.log
