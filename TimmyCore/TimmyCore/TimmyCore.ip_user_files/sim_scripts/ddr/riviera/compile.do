vlib work
vlib riviera

vlib riviera/xil_defaultlib

vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/clocking/mig_7series_v4_0_clk_ibuf.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/clocking/mig_7series_v4_0_infrastructure.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/clocking/mig_7series_v4_0_iodelay_ctrl.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/clocking/mig_7series_v4_0_tempmon.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/controller/mig_7series_v4_0_arb_mux.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/controller/mig_7series_v4_0_arb_row_col.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/controller/mig_7series_v4_0_arb_select.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/controller/mig_7series_v4_0_bank_cntrl.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/controller/mig_7series_v4_0_bank_common.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/controller/mig_7series_v4_0_bank_compare.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/controller/mig_7series_v4_0_bank_mach.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/controller/mig_7series_v4_0_bank_queue.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/controller/mig_7series_v4_0_bank_state.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/controller/mig_7series_v4_0_col_mach.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/controller/mig_7series_v4_0_mc.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/controller/mig_7series_v4_0_rank_cntrl.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/controller/mig_7series_v4_0_rank_common.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/controller/mig_7series_v4_0_rank_mach.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/controller/mig_7series_v4_0_round_robin_arb.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/ecc/mig_7series_v4_0_ecc_buf.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/ecc/mig_7series_v4_0_ecc_dec_fix.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/ecc/mig_7series_v4_0_ecc_gen.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/ecc/mig_7series_v4_0_ecc_merge_enc.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/ecc/mig_7series_v4_0_fi_xor.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/ip_top/mig_7series_v4_0_memc_ui_top_std.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/ip_top/mig_7series_v4_0_mem_intfc.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_byte_group_io.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_byte_lane.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_calib_top.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_if_post_fifo.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_mc_phy.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_mc_phy_wrapper.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_of_pre_fifo.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_4lanes.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ck_addr_cmd_delay.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_dqs_found_cal.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_dqs_found_cal_hr.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_init.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_cntlr.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_data.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_edge.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_lim.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_mux.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_po_cntlr.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_samp.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_oclkdelay_cal.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_prbs_rdlvl.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_rdlvl.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_tempmon.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_wrcal.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_wrlvl.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_wrlvl_off_delay.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_prbs_gen.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_poc_cc.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_poc_edge_store.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_poc_meta.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_poc_pd.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_poc_tap_base.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_poc_top.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/ui/mig_7series_v4_0_ui_cmd.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/ui/mig_7series_v4_0_ui_rd_data.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/ui/mig_7series_v4_0_ui_top.v" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/ui/mig_7series_v4_0_ui_wr_data.v" \

vcom -work xil_defaultlib -93 \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_top.vhd" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/ddr_mig_sim.vhd" \
"../../../../TimmyCore.srcs/sources_1/ip/ddr/ddr/user_design/rtl/ddr.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

