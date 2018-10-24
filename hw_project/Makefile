all:
	@echo "Valid make targets are:"
	@echo " warmup    - to create the warm-up project"
	@echo " build     - to create the project"
	@echo " open      - to open the created project"
	@echo " clean     - to delete the project files (your design in \src will be saved)"

warmup:
	vivado -mode batch -source tcl/build_warmup.tcl


build: ipcore project

ipcore:
	vivado -mode batch -source tcl/build_ipcore_interface.tcl

project:
	vivado -mode batch -source tcl/build_project.tcl

open:
	vivado project_hw/project_hw.xpr -tempDir /tmp &

clean:
	rm -rf vivado.* vivado_* .Xil/ webtalk* -f
	rm -rf project_hw project_ipcores