// The Qu Processor CPU core module
// Created:     2025-06-27
// Modified:    2025-07-14

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_CORE
`define QU_CORE

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module qu_core
    #(
        parameter MEM_INIT_FILE = "",
        parameter INSTR_WIDTH = QU_INSTR_WIDTH,
        parameter PC_WIDTH = QU_PC_WIDTH,
        parameter FIFO_IF_ID_DEPTH = 12,
        parameter FIFO_ID_MP_DEPTH = 12,
        parameter FIFO_MP_RN_DEPTH = 12
    )(
        input   logic clk,
        input   logic rst,
        
        input   logic stall,

        input   logic if_stall,
        input   logic id_stall,
        input   logic mp_stall,
        input   logic rn_stall,

        input   logic schedule_en
    );

    localparam DMEM_DEPTH = 2**PC_WIDTH;

    logic startup_ctrl_if_en_out;
    logic startup_ctrl_id_en_out;

    pc_t pmem_addr_in;
    logic pmem_en_in;
    logic [INSTR_WIDTH-1:0] pmem_dout_out;

    logic front_end_if_en;
    logic front_end_id_en;
    logic front_end_branch_in;
    logic front_end_jump_in;
    logic front_end_exception_in;
    logic front_end_stall_in;
    pc_t front_end_pc_override_in;
    logic front_end_busy_table_wr_en_in;
    pc_t front_end_next_pc_out;
    logic [INSTR_WIDTH-1:0] front_end_instr_in;
    phy_rf_addr_t front_end_phyreg_renamed_free_reg_addr_in;

    logic [PHY_RF_ADDR_WIDTH-1:0] front_end_busy_table_wr_addr_in;
    logic front_end_busy_table_wr_data_in;
    rob_addr_t front_end_rob_tail_ptr_in;
    logic front_end_rob_incr_tail_ptr_out;
    logic [PHY_RF_ADDR_WIDTH-1:0] front_end_rf_rs1_addr_out;
    logic [PHY_RF_ADDR_WIDTH-1:0] front_end_rf_rs2_addr_out;
    logic [31:0] front_end_rf_rs1_data_in;
    logic [31:0] front_end_rf_rs2_data_in;
    logic front_end_res_st_wr_en_out;
    res_st_addr_t front_end_res_st_wr_addr_out;
    res_st_cell_t front_end_res_st_data_out;
    logic front_end_rob_full_in;

    logic res_st_wr_en_in;
    res_st_addr_t res_st_wr_addr_in;
    res_st_cell_t res_st_wr_in;
    res_st_addr_t res_st_rd1_addr_in;
    res_st_cell_t res_st_rd1_out;
    res_st_addr_t res_st_rd2_addr_in;
    res_st_cell_t res_st_rd2_out;
    res_st_addr_t res_st_rd3_addr_in;
    res_st_cell_t res_st_rd3_out;
    res_st_addr_t res_st_rd4_addr_in;
    res_st_cell_t res_st_rd4_out;
    logic res_st_retire_en;
    rob_addr_t res_st_retire_addr_in;
    logic [31:0] res_st_retire_value_in;

    logic [PHY_RF_ADDR_WIDTH-1:0] rf_rs1_addr_in;
    logic [PHY_RF_ADDR_WIDTH-1:0] rf_rs2_addr_in;
    logic [31:0] rf_rs1_data_out;
    logic [31:0] rf_rs2_data_out;
    logic rf_wr_en;
    phy_rf_addr_t rf_rd_addr;
    phy_rf_data_t rf_data_in;

    logic [$clog2(DMEM_DEPTH)-1:0] dmem_addr_in;
    logic [31:0] dmem_din_in;
    logic dmem_wr_en;
    logic dmem_en_in;
    logic dmem_valid_out;
    logic [31:0] dmem_dout_out;

    res_st_addr_t back_end_res_st_rd1_addr_out;
    res_st_cell_t back_end_res_st_rd1_in;
    res_st_addr_t back_end_res_st_rd2_addr_out;
    res_st_cell_t back_end_res_st_rd2_in;
    res_st_addr_t back_end_res_st_rd3_addr_out;
    res_st_cell_t back_end_res_st_rd3_in;
    res_st_addr_t back_end_res_st_rd4_addr_out;
    res_st_cell_t back_end_res_st_rd4_in;
    logic back_end_res_st_retire_en_out;
    rob_addr_t back_end_res_st_retire_rob_addr_out;
    phy_rf_data_t back_end_res_st_retire_value_out;
    logic back_end_phy_rf_wr_en_out;
    phy_rf_addr_t back_end_phy_rf_wr_addr_out;
    phy_rf_data_t back_end_phy_rf_wr_data_out;
    logic back_end_busy_table_wr_en_out;
    phy_rf_addr_t back_end_busy_table_wr_addr_out;
    logic back_end_busy_table_wr_data_out;
    phy_rf_addr_t back_end_phyreg_renamed_free_reg_addr_out;
    rob_addr_t back_end_rob_tail_ptr_out;
    logic back_end_rob_incr_tail_ptr_in;
    logic back_end_rob_full_out;
    logic back_end_mispredicted_branch_out;
    pc_t back_end_pc_to_jump_out;
    logic back_end_dmem_wr_en_out;
    logic back_end_dmem_rd_en_out;
    logic [31:0] back_end_dmem_addr_out;
    logic [31:0] back_end_dmem_data_out;
    logic back_end_dmem_valid_in;
    logic [31:0] back_end_dmem_data_in;

    assign pmem_addr_in = {2'b0, front_end_next_pc_out[PC_WIDTH-1:2]};
    assign pmem_en_in = !stall;

    assign front_end_if_en = startup_ctrl_if_en_out;
    assign front_end_id_en = startup_ctrl_if_en_out;
    assign front_end_branch_in = back_end_mispredicted_branch_out;
    assign front_end_jump_in = 'b0;
    assign front_end_exception_in = 'b0;
    assign front_end_stall_in = stall;
    assign front_end_instr_in = pmem_dout_out;
    assign front_end_pc_override_in = back_end_pc_to_jump_out;
    assign front_end_rf_rs1_data_in = rf_rs1_data_out;
    assign front_end_rf_rs2_data_in = rf_rs2_data_out;
    assign front_end_busy_table_wr_en_in = back_end_busy_table_wr_en_out;
    assign front_end_busy_table_wr_addr_in = back_end_busy_table_wr_addr_out;
    assign front_end_busy_table_wr_data_in = back_end_busy_table_wr_data_out;
    assign front_end_phyreg_renamed_free_reg_addr_in = back_end_phyreg_renamed_free_reg_addr_out;
    assign front_end_rob_tail_ptr_in = back_end_rob_tail_ptr_out;
    assign front_end_rob_full_in = back_end_rob_full_out;

    assign res_st_wr_en_in = front_end_res_st_wr_en_out;
    assign res_st_wr_addr_in = front_end_res_st_wr_addr_out;
    assign res_st_wr_in = front_end_res_st_data_out;
    assign res_st_rd1_addr_in = back_end_res_st_rd1_addr_out;
    assign res_st_rd2_addr_in = back_end_res_st_rd2_addr_out;
    assign res_st_rd3_addr_in = back_end_res_st_rd3_addr_out;
    assign res_st_rd4_addr_in = back_end_res_st_rd4_addr_out;
    assign res_st_retire_en = back_end_res_st_retire_en_out;
    assign res_st_retire_addr_in = back_end_res_st_retire_rob_addr_out;
    assign res_st_retire_value_in = back_end_res_st_retire_value_out;

    assign rf_rs1_addr_in = front_end_rf_rs1_addr_out;
    assign rf_rs2_addr_in = front_end_rf_rs2_addr_out;
    assign rf_wr_en = back_end_phy_rf_wr_en_out;
    assign rf_rd_addr = back_end_phy_rf_wr_addr_out;
    assign rf_data_in = back_end_phy_rf_wr_data_out;

    assign dmem_addr_in = back_end_dmem_addr_out;
    assign dmem_din_in = back_end_dmem_data_out;
    assign dmem_wr_en = back_end_dmem_wr_en_out;
    assign dmem_en_in = back_end_dmem_wr_en_out | back_end_dmem_rd_en_out;

    assign back_end_res_st_rd1_in = res_st_rd1_out;
    assign back_end_res_st_rd2_in = res_st_rd2_out;
    assign back_end_res_st_rd3_in = res_st_rd3_out;
    assign back_end_res_st_rd4_in = res_st_rd4_out;
    assign back_end_rob_incr_tail_ptr_in = front_end_rob_incr_tail_ptr_out;
    assign back_end_dmem_valid_in = dmem_valid_out;
    assign back_end_dmem_data_in = dmem_dout_out;

    startup_ctrl qu_startup_ctrl (
        .clk(clk),
        .rst(rst),
        .if_en(startup_ctrl_if_en_out),
        .id_en(startup_ctrl_id_en_out)
    );

    front_end #(
        .INSTR_WIDTH(INSTR_WIDTH),
        .PC_WIDTH(PC_WIDTH),
        .FIFO_IF_ID_DEPTH(FIFO_IF_ID_DEPTH),
        .FIFO_ID_MP_DEPTH(FIFO_ID_MP_DEPTH),
        .FIFO_MP_RN_DEPTH(FIFO_MP_RN_DEPTH)
    ) qu_front_end (
        .clk(clk),
        .rst(rst),
        .if_en(front_end_if_en),
        .id_en(front_end_id_en),
        .branch(front_end_branch_in),
        .jump(front_end_jump_in),
        .exception(front_end_exception_in),
        .stall(front_end_stall_in),
        .pc_override(front_end_pc_override_in),
        .if_stall(if_stall),
        .id_stall(id_stall),
        .mp_stall(mp_stall),
        .rn_stall(rn_stall),
        .next_pc(front_end_next_pc_out),
        .instr(front_end_instr_in),
        .busy_table_wr_en(front_end_busy_table_wr_en_in),
        .busy_table_wr_addr(front_end_busy_table_wr_addr_in),
        .busy_table_wr_data(front_end_busy_table_wr_data_in),
        .phyreg_renamed_free_reg_addr(front_end_phyreg_renamed_free_reg_addr_in),
        .rob_tail_ptr(front_end_rob_tail_ptr_in),
        .rob_incr_tail_ptr(front_end_rob_incr_tail_ptr_out),
        .rf_rs1_addr(front_end_rf_rs1_addr_out),
        .rf_rs2_addr(front_end_rf_rs2_addr_out),
        .rf_rs1_data_in(front_end_rf_rs1_data_in),
        .rf_rs2_data_in(front_end_rf_rs2_data_in),
        .res_st_wr_en_out(front_end_res_st_wr_en_out),
        .res_st_wr_addr_out(front_end_res_st_wr_addr_out),
        .res_st_data_out(front_end_res_st_data_out),
        .rob_full(front_end_rob_full_in)
    );

    res_st #(
        .RES_ST_DEPTH(RES_ST_DEPTH)
    ) qu_res_st (
        .clk(clk),
        .rst(rst | back_end_mispredicted_branch_out),
        .wr_en(res_st_wr_en_in),
        .wr_addr(res_st_wr_addr_in),
        .wr_in(res_st_wr_in),
        .rd1_addr(res_st_rd1_addr_in),
        .rd1_out(res_st_rd1_out),
        .rd2_addr(res_st_rd2_addr_in),
        .rd2_out(res_st_rd2_out),
        .rd3_addr(res_st_rd3_addr_in),
        .rd3_out(res_st_rd3_out),
        .rd4_addr(res_st_rd4_addr_in),
        .rd4_out(res_st_rd4_out),
        .retire_en(res_st_retire_en),
        .retire_addr(res_st_retire_addr_in),
        .retire_value(res_st_retire_value_in)
    );

    rf #(
        .RF_WIDTH(32),
        .RF_DEPTH(PHY_RF_DEPTH)
    ) qu_phy_rf (
        .clk(clk),
        .rst(rst),
        .rs1_addr(rf_rs1_addr_in),
        .rs2_addr(rf_rs2_addr_in),
        .rs1_data_out(rf_rs1_data_out),
        .rs2_data_out(rf_rs2_data_out),
        .wr_en(rf_wr_en),
        .rd_addr(rf_rd_addr),
        .data_in(rf_data_in)
    );

    back_end qu_back_end (
        .clk(clk),
        .rst(rst),
        .schedule_en(schedule_en),
        .res_st_rd1_addr(back_end_res_st_rd1_addr_out),
        .res_st_rd1_in(back_end_res_st_rd1_in),
        .res_st_rd2_addr(back_end_res_st_rd2_addr_out),
        .res_st_rd2_in(back_end_res_st_rd2_in),
        .res_st_rd3_addr(back_end_res_st_rd3_addr_out),
        .res_st_rd3_in(back_end_res_st_rd3_in),
        .res_st_rd4_addr(back_end_res_st_rd4_addr_out),
        .res_st_rd4_in(back_end_res_st_rd4_in),
        .res_st_retire_en(back_end_res_st_retire_en_out),
        .res_st_retire_rob_addr(back_end_res_st_retire_rob_addr_out),
        .res_st_retire_value(back_end_res_st_retire_value_out),
        .phy_rf_wr_en(back_end_phy_rf_wr_en_out),
        .phy_rf_wr_addr(back_end_phy_rf_wr_addr_out),
        .phy_rf_wr_data(back_end_phy_rf_wr_data_out),
        .busy_table_wr_en(back_end_busy_table_wr_en_out),
        .busy_table_wr_addr(back_end_busy_table_wr_addr_out),
        .busy_table_wr_data(back_end_busy_table_wr_data_out),
        .phyreg_renamed_free_reg_addr(back_end_phyreg_renamed_free_reg_addr_out),
        .rob_tail_ptr(back_end_rob_tail_ptr_out),
        .rob_incr_tail_ptr(back_end_rob_incr_tail_ptr_in),
        .rob_full(back_end_rob_full_out),
        .mispredicted_branch(back_end_mispredicted_branch_out),
        .pc_to_jump(back_end_pc_to_jump_out),
        .dmem_wr_en(back_end_dmem_wr_en_out),
        .dmem_rd_en(back_end_dmem_rd_en_out),
        .dmem_addr(back_end_dmem_addr_out),
        .dmem_data_out(back_end_dmem_data_out),
        .dmem_valid_in(back_end_dmem_valid_in),
        .dmem_data_in(back_end_dmem_data_in)
    );

    // a: pmem, b: dmem
    ram_dp_rf #(
        .NB_COL(1),
        .COL_WIDTH(32),
        .RAM_DEPTH(2**PC_WIDTH),
        .RAM_PERFORMANCE("LOW_LATENCY"),
        .INIT_FILE(MEM_INIT_FILE)
    ) qu_mem (
        .addra(pmem_addr_in),
        .addrb(dmem_addr_in),
        .dina(),
        .dinb(dmem_din_in),
        .clka(clk),
        .wea(4'b0),
        .web(dmem_wr_en),
        .ena(pmem_en_in),
        .enb(dmem_en_in),
        .rsta(rst),
        .rstb(rst),
        .regcea(1'b1),
        .regceb(1'b1),
        .valida(),
        .validb(dmem_valid_out),
        .douta(pmem_dout_out),
        .doutb(dmem_dout_out)
    );

endmodule

`endif
