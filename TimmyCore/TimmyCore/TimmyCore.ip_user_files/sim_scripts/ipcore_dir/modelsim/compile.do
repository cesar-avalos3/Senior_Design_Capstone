vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vcom -work xil_defaultlib -64 -93 \
"C:/Users/Cesar/Documents/GitHub/Ram2Ddr_RefComp/Source/Ram2DdrXadc_RefComp/ipcore_dir/ddr_sim_netlist.vhdl" \


