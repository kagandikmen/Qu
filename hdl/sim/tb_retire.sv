// Testbench for the retire stage of The Qu Processor
// Created:     2025-07-06
// Modified:    2025-07-15

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`timescale 1ns/1ps

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module tb_retire
    #()();

    logic clk;
    logic rst;

    phy_rf_data_t value1_in;
    phy_rf_data_t value2_in;
    logic comp_result_in;
    res_st_cell_t op1_in;
    res_st_cell_t op2_in;

    logic phy_rf_wr_en;
    phy_rf_addr_t phy_rf_wr_addr;
    phy_rf_data_t phy_rf_wr_data;

    phy_rf_addr_t phyreg_renamed_free_reg_addr;

    logic busy_table_wr_en;
    logic [PHY_RF_ADDR_WIDTH-1:0] busy_table_wr_addr;
    logic busy_table_wr_data;
    rob_addr_t rob_tail_ptr;
    logic rob_incr_tail_ptr;
    logic rob_full;

    logic retire_en;
    rob_addr_t retire_rob_addr;
    phy_rf_data_t retire_value;

    logic mispredicted_branch;
    pc_t pc_to_jump;

    logic [3:0] dmem_wr_en_out;
    logic dmem_rd_en_out;
    logic [31:0] dmem_addr_out;
    logic [31:0] dmem_data_out;
    logic dmem_valid_in;
    logic [$clog2(MEM_DEPTH)-1:0] dmem_valid_addr_in;
    logic [31:0] dmem_data_in;

    retire dut (
        .clk(clk),
        .rst(rst),
        .value1_in(value1_in),
        .value2_in(value2_in),
        .comp_result_in(comp_result_in),
        .op1_in(op1_in),
        .op2_in(op2_in),
        .phy_rf_wr_en(phy_rf_wr_en),
        .phy_rf_wr_addr(phy_rf_wr_addr),
        .phy_rf_wr_data(phy_rf_wr_data),
        .phyreg_renamed_free_reg_addr(phyreg_renamed_free_reg_addr),
        .busy_table_wr_en(busy_table_wr_en),
        .busy_table_wr_addr(busy_table_wr_addr),
        .busy_table_wr_data(busy_table_wr_data),
        .rob_tail_ptr(rob_tail_ptr),
        .rob_incr_tail_ptr(rob_incr_tail_ptr),
        .rob_full(rob_full),
        .retire_en(retire_en),
        .retire_rob_addr(retire_rob_addr),
        .retire_value(retire_value),
        .mispredicted_branch(mispredicted_branch),
        .pc_to_jump(pc_to_jump),
        .dmem_wr_en_out(dmem_wr_en_out),
        .dmem_rd_en_out(dmem_rd_en_out),
        .dmem_addr_out(dmem_addr_out),
        .dmem_data_out(dmem_data_out),
        .dmem_valid_in(dmem_valid_in),
        .dmem_valid_addr_in(dmem_valid_addr_in),
        .dmem_data_in(dmem_data_in)
    );

    always #5   clk = ~clk;

    initial
    begin
        clk <= 1'b0;
        rst <= 1'b0;
        value1_in <= 'd15;
        value2_in <= 'd25;
        comp_result_in <= 'b0;
        op1_in <= 'b0;
        op2_in <= 'b0;
        rob_incr_tail_ptr <= 1'b1;
        dmem_valid_in <= 1'b0;
        dmem_valid_addr_in <= 'b0;
        dmem_data_in <= 'd4;

        @(posedge clk);
        rst <= 1'b1;

        repeat(4) @(posedge clk);
        rst <= 1'b0;
        
        op1_in.busy <= 1'b1;
        op1_in.op <= 'b011;
        op1_in.qj <= 'd0;
        op1_in.qk <= 'd0;
        op1_in.vj <= 'd5;
        op1_in.vk <= 'd10;
        op1_in.a <= 'b0;
        op1_in.dest <= 'd3;
        op1_in.rob_addr <= 'd1;

        @(posedge clk);
        op1_in.busy <= 1'b1;
        op1_in.op <= 'b011;
        op1_in.qj <= 'd0;
        op1_in.qk <= 'd3;
        op1_in.vj <= 'd8;
        op1_in.vk <= 'd0;
        op1_in.a <= 'b0;
        op1_in.dest <= 'd4;
        op1_in.rob_addr <= 'd2;

        @(posedge clk);
        op1_in.op <= 'b0;

        #200;
        $finish;
    end

endmodule
