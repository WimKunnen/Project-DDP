all: 
	@echo "Valid make targets are:"
	@echo " build     - to create the project"
	@echo " open      - to open the created project"
	@echo " clean     - to delete the project files (your design in \src will be saved)"
	@echo " hw_import - to import the most updated HDF from Vivado"

open:
	xsdk -workspace ./project_sw &

hw_import:
	if [ -a ../hw_project/project_hw/project_hw.sdk/rsa_project_wrapper.hdf ]; then rm -f hwdef.hdf; cp ../hw_project/project_hw/project_hw.sdk/rsa_project_wrapper.hdf hwdef.hdf; fi;
	if [ -a ../hw_project/project_hw/project_hw.sdk/rsa_project_wrapper.hdf ]; then rm -rf ../hw_project/project_hw/project_hw.sdk; fi;
	
build:
	xsdk -batch -source src/tcl/sdk.tcl
	cp -f project_sw/sw_design/src/lscript.ld src/sw/.
	cp -f project_sw/sw_design/src/Xilinx.spec src/sw/.
	rm -rf project_sw/sw_design/src
	ln -s ../../src/sw/ project_sw/sw_design/src
		
clean:
	rm -rf vivado.* vivado_* .Xil/ webtalk* project_sw