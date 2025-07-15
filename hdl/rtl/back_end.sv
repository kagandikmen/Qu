// Top back-end module of The Qu Processor
// Created:     2025-07-03
// Modified:    2025-07-15

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_BACK
`define QU_BACK

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module back_end
    #()(
        input   logic clk,
        input   logic rst,
        input   logic schedule_en,

        // reservation station read interface
        output  res_st_addr_t res_st_rd1_addr,
        input   res_st_cell_t res_st_rd1_in,
        output  res_st_addr_t res_st_rd2_addr,
        input   res_st_cell_t res_st_rd2_in,
        output  res_st_addr_t res_st_rd3_addr,
        input   res_st_cell_t res_st_rd3_in,
        output  res_st_addr_t res_st_rd4_addr,
        input   res_st_cell_t res_st_rd4_in,

        // reservation station retire interface
        output  logic retire_en,
        output  rob_addr_t retire_rob_addr,
        output  phy_rf_data_t retire_value,

        // register file writeback interface
        output  logic phy_rf_wr_en,
        output  phy_rf_addr_t phy_rf_wr_addr,
        output  phy_rf_data_t phy_rf_wr_data,

        // busy table interface
        output  logic busy_table_wr_en,
        output  phy_rf_addr_t busy_table_wr_addr,
        output  logic busy_table_wr_data,

        // map stage interface
        output  phy_rf_addr_t phyreg_renamed_free_reg_addr,

        // rename stage interface
        output  rob_addr_t rob_tail_ptr,
        input   logic rob_incr_tail_ptr,
        output  logic rob_full,

        output  logic mispredicted_branch,
        output  pc_t pc_to_jump,

        // data memory interface
        output  logic [3:0] dmem_wr_en,
        output  logic dmem_rd_en,
        output  logic [31:0] dmem_addr,
        output  logic [31:0] dmem_data_out,
        input   logic dmem_valid_in,
        input   logic [$clog2(MEM_DEPTH)-1:0] dmem_valid_addr_in,
        input   logic [31:0] dmem_data_in
    );

    res_st_addr_t schedule_res_st_rd1_addr_out;
    res_st_cell_t schedule_res_st_rd1_in;
    res_st_addr_t schedule_res_st_rd2_addr_out;
    res_st_cell_t schedule_res_st_rd2_in;
    res_st_addr_t schedule_res_st_rd3_addr_out;
    res_st_cell_t schedule_res_st_rd3_in;
    res_st_addr_t schedule_res_st_rd4_addr_out;
    res_st_cell_t schedule_res_st_rd4_in;
    logic schedule_fifo_wr_en_out;
    res_st_cell_t schedule_op_out;

    logic fifo_sh_ex_rd_en;
    res_st_cell_t fifo_sh_ex_data_out;
    logic fifo_sh_ex_wr_en;
    res_st_cell_t fifo_sh_ex_data_in;
    logic fifo_sh_ex_empty_out;
    logic fifo_sh_ex_full_out;

    res_st_cell_t execute_op_in;
    logic [31:0] execute_value_out;
    logic execute_comp_result_out;
    res_st_cell_t execute_op_out;

    logic fifo_ex_rt_rd_en;
    logic [$bits(res_st_cell_t)+32+1-1:0] fifo_ex_rt_data_out;
    logic fifo_ex_rt_wr_en;
    logic [$bits(res_st_cell_t)+32+1-1:0] fifo_ex_rt_data_in;
    logic fifo_ex_rt_empty_out;
    logic fifo_ex_rt_full_out;

    logic [31:0] retire_value_in;
    logic retire_comp_result_in;
    res_st_cell_t retire_op_in;
    logic phy_rf_rf_wr_en_out;
    phy_rf_addr_t retire_phy_rf_wr_addr_out;
    phy_rf_data_t retire_phy_rf_wr_data_out;
    phy_rf_addr_t retire_phyreg_renamed_free_reg_addr_out;
    logic retire_busy_table_wr_en_out;
    phy_rf_addr_t retire_busy_table_wr_addr_out;
    logic retire_busy_table_wr_data_out;
    rob_addr_t retire_rob_tail_ptr_out;
    logic retire_rob_incr_tail_ptr_in;
    logic retire_rob_full_out;
    logic retire_retire_en_out;
    rob_addr_t retire_retire_rob_addr_out;
    phy_rf_data_t retire_retire_value_out;
    logic retire_mispredicted_branch_out;
    pc_t retire_pc_to_jump_out;
    logic [3:0] retire_dmem_wr_en_out;
    logic retire_dmem_rd_en_out;
    logic [31:0] retire_dmem_addr_out;
    logic [31:0] retire_dmem_data_out;
    logic retire_dmem_valid_in;
    logic [$clog2(MEM_DEPTH)-1:0] retire_dmem_valid_addr_in;
    logic [31:0] retire_dmem_data_in;

    assign schedule_res_st_rd1_in = res_st_rd1_in;
    assign schedule_res_st_rd2_in = res_st_rd2_in;
    assign schedule_res_st_rd3_in = res_st_rd3_in;
    assign schedule_res_st_rd4_in = res_st_rd4_in;

    assign fifo_sh_ex_rd_en = !fifo_sh_ex_empty_out;
    assign fifo_sh_ex_wr_en = schedule_fifo_wr_en_out;
    assign fifo_sh_ex_data_in = schedule_op_out;

    assign execute_op_in = fifo_sh_ex_data_out;

    assign fifo_ex_rt_rd_en = !fifo_ex_rt_empty_out;
    assign fifo_ex_rt_wr_en = execute_op_out[0];
    assign fifo_ex_rt_data_in = {execute_comp_result_out, execute_value_out, execute_op_out};

    assign retire_value_in = fifo_ex_rt_data_out[($bits(fifo_ex_rt_data_out)-2) -: 32];
    assign retire_comp_result_in = fifo_ex_rt_data_out[$bits(fifo_ex_rt_data_out)-1];
    assign retire_op_in = fifo_ex_rt_data_out[$bits(res_st_cell_t)-1:0];
    assign retire_rob_incr_tail_ptr_in = rob_incr_tail_ptr;
    assign retire_dmem_valid_in = dmem_valid_in;
    assign retire_dmem_valid_addr_in = dmem_valid_addr_in;
    assign retire_dmem_data_in = dmem_data_in;

    assign res_st_rd1_addr = schedule_res_st_rd1_addr_out;
    assign res_st_rd2_addr = schedule_res_st_rd2_addr_out;
    assign res_st_rd3_addr = schedule_res_st_rd3_addr_out;
    assign res_st_rd4_addr = schedule_res_st_rd4_addr_out;
    assign retire_en = retire_retire_en_out;
    assign retire_rob_addr = retire_retire_rob_addr_out;
    assign retire_value = retire_retire_value_out;
    assign phy_rf_wr_en = retire_phy_rf_wr_en_out;
    assign phy_rf_wr_addr = retire_phy_rf_wr_addr_out;
    assign phy_rf_wr_data = retire_phy_rf_wr_data_out;
    assign busy_table_wr_en = retire_busy_table_wr_en_out;
    assign busy_table_wr_addr = retire_busy_table_wr_addr_out;
    assign busy_table_wr_data = retire_busy_table_wr_data_out;
    assign rob_tail_ptr = retire_rob_tail_ptr_out;
    assign rob_full = retire_rob_full_out;

    assign phyreg_renamed_free_reg_addr = retire_phyreg_renamed_free_reg_addr_out;
    assign mispredicted_branch = retire_mispredicted_branch_out;
    assign pc_to_jump = retire_pc_to_jump_out;
    assign dmem_wr_en = retire_dmem_wr_en_out;
    assign dmem_rd_en = retire_dmem_rd_en_out;
    assign dmem_addr = retire_dmem_addr_out;
    assign dmem_data_out = retire_dmem_data_out;

    schedule qu_schedule (
        .clk(clk),
        .rst(rst | retire_mispredicted_branch_out),
        .en(schedule_en),
        .res_st_rd1_addr(schedule_res_st_rd1_addr_out),
        .res_st_rd1_in(schedule_res_st_rd1_in),
        .res_st_rd2_addr(schedule_res_st_rd2_addr_out),
        .res_st_rd2_in(schedule_res_st_rd2_in),
        .res_st_rd3_addr(schedule_res_st_rd3_addr_out),
        .res_st_rd3_in(schedule_res_st_rd3_in),
        .res_st_rd4_addr(schedule_res_st_rd4_addr_out),
        .res_st_rd4_in(schedule_res_st_rd4_in),
        .fifo_wr_en(schedule_fifo_wr_en_out),
        .op_out(schedule_op_out)
    );

    fifo #(
        .FIFO_WIDTH($bits(res_st_cell_t)),
        .FIFO_DEPTH(4)
    ) qu_fifo_sh_ex (
        .clk(clk),
        .rst(rst | retire_mispredicted_branch_out),
        .rd_en(fifo_sh_ex_rd_en),
        .data_out(fifo_sh_ex_data_out),
        .wr_en(fifo_sh_ex_wr_en),
        .data_in(fifo_sh_ex_data_in),
        .empty(fifo_sh_ex_empty_out),
        .almost_empty(),
        .full(fifo_sh_ex_full_out),
        .almost_full()
    );

    execute qu_execute (
        .op_in(execute_op_in),
        .value_out(execute_value_out),
        .comp_result(execute_comp_result_out),
        .op_out(execute_op_out)
    );

    fifo #(
        .FIFO_WIDTH($bits(res_st_cell_t)+32+1),
        .FIFO_DEPTH(4)
    ) qu_fifo_ex_rt (
        .clk(clk),
        .rst(rst | retire_mispredicted_branch_out),
        .rd_en(fifo_ex_rt_rd_en),
        .data_out(fifo_ex_rt_data_out),
        .wr_en(fifo_ex_rt_wr_en),
        .data_in(fifo_ex_rt_data_in),
        .empty(fifo_ex_rt_empty_out),
        .almost_empty(),
        .full(fifo_ex_rt_full_out),
        .almost_full()
    );

    retire qu_retire (
        .clk(clk),
        .rst(rst | retire_mispredicted_branch_out),
        .value_in(retire_value_in),
        .comp_result_in(retire_comp_result_in),
        .op_in(retire_op_in),
        .phy_rf_wr_en(retire_phy_rf_wr_en_out),
        .phy_rf_wr_addr(retire_phy_rf_wr_addr_out),
        .phy_rf_wr_data(retire_phy_rf_wr_data_out),
        .phyreg_renamed_free_reg_addr(retire_phyreg_renamed_free_reg_addr_out),
        .busy_table_wr_en(retire_busy_table_wr_en_out),
        .busy_table_wr_addr(retire_busy_table_wr_addr_out),
        .busy_table_wr_data(retire_busy_table_wr_data_out),
        .rob_tail_ptr(retire_rob_tail_ptr_out),
        .rob_incr_tail_ptr(retire_rob_incr_tail_ptr_in),
        .rob_full(retire_rob_full_out),
        .retire_en(retire_retire_en_out),
        .retire_rob_addr(retire_retire_rob_addr_out),
        .retire_value(retire_retire_value_out),
        .mispredicted_branch(retire_mispredicted_branch_out),
        .pc_to_jump(retire_pc_to_jump_out),
        .dmem_wr_en_out(retire_dmem_wr_en_out),
        .dmem_rd_en_out(retire_dmem_rd_en_out),
        .dmem_addr_out(retire_dmem_addr_out),
        .dmem_data_out(retire_dmem_data_out),
        .dmem_valid_in(retire_dmem_valid_in),
        .dmem_valid_addr_in(retire_dmem_valid_addr_in),
        .dmem_data_in(retire_dmem_data_in)
    );

endmodule

`endif
