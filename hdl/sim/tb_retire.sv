// Testbench for the retire stage of The Qu Processor
// Created:     2025-07-06
// Modified:    2025-07-13

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

    phy_rf_data_t value_in;
    logic comp_result_in;
    res_st_cell_t op_in;

    logic phy_rf_wr_en;
    phy_rf_addr_t phy_rf_wr_addr;
    phy_rf_data_t phy_rf_wr_data;

    logic busy_table_wr_en;
    logic [PHY_RF_ADDR_WIDTH-1:0] busy_table_wr_addr;
    logic busy_table_wr_data;
    rob_addr_t rob_tail_ptr;
    logic rob_incr_tail_ptr;
    logic rob_full;

    logic res_st_retire_en;
    rob_addr_t res_st_retire_rob_addr;
    phy_rf_data_t res_st_retire_value;

    retire dut (
        .clk(clk),
        .rst(rst),
        .value_in(value_in),
        .comp_result_in(comp_result_in),
        .op_in(op_in),
        .phy_rf_wr_en(phy_rf_wr_en),
        .phy_rf_wr_addr(phy_rf_wr_addr),
        .phy_rf_wr_data(phy_rf_wr_data),
        .busy_table_wr_en(busy_table_wr_en),
        .busy_table_wr_addr(busy_table_wr_addr),
        .busy_table_wr_data(busy_table_wr_data),
        .rob_tail_ptr(rob_tail_ptr),
        .rob_incr_tail_ptr(rob_incr_tail_ptr),
        .rob_full(rob_full),
        .res_st_retire_en(res_st_retire_en),
        .res_st_retire_rob_addr(res_st_retire_rob_addr),
        .res_st_retire_value(res_st_retire_value)
    );

    always #5   clk = ~clk;

    initial
    begin
        clk <= 1'b0;
        rst <= 1'b0;
        value_in <= 'd15;
        comp_result_in <= 'b0;
        op_in <= 'b0;
        rob_incr_tail_ptr <= 1'b1;

        @(posedge clk);
        rst <= 1'b1;

        repeat(4) @(posedge clk);
        rst <= 1'b0;
        
        op_in.busy <= 1'b1;
        op_in.op <= 14'b011;
        op_in.qj <= 'd0;
        op_in.qk <= 'd0;
        op_in.vj <= 'd5;
        op_in.vk <= 'd10;
        op_in.a <= 'b0;
        op_in.dest <= 'd3;
        op_in.rob_addr <= 'd1;

        @(posedge clk);
        op_in.busy <= 1'b1;
        op_in.op <= 14'b011;
        op_in.qj <= 'd0;
        op_in.qk <= 'd3;
        op_in.vj <= 'd8;
        op_in.vk <= 'd0;
        op_in.a <= 'b0;
        op_in.dest <= 'd4;
        op_in.rob_addr <= 'd2;

        @(posedge clk);
        op_in.op <= 14'b0;

        #200;
        $finish;
    end

endmodule
