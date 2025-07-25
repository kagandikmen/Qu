// Rename stage testbench
// Created:     2025-06-30
// Modified:    2025-07-15

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`timescale 1ns/1ps

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module tb_rename
    #()();

    logic clk;
    logic rst;

    uop_t uop_in;

    logic [PHY_RF_ADDR_WIDTH-1:0] busy_table_rd1_addr;
    logic busy_table_data1_in;
    logic [PHY_RF_ADDR_WIDTH-1:0] busy_table_rd2_addr;
    logic busy_table_data2_in;

    logic [PHY_RF_ADDR_WIDTH-1:0] phy_rf_rs1_addr_out;
    logic [31:0] phy_rf_rs1_data_in;
    logic [PHY_RF_ADDR_WIDTH-1:0] phy_rf_rs2_addr_out;
    logic [31:0] phy_rf_rs2_data_in;

    logic res_st_wr_en_out;
    res_st_addr_t res_st_wr_addr_out;
    res_st_cell_t res_st_data_out;

    rob_addr_t rob_tail_ptr;
    logic rob_incr_tail_ptr;

    logic retire_en;
    rob_addr_t retire_rob_addr;

    rename #(
    ) dut (
        .clk(clk),
        .rst(rst),
        .uop_in(uop_in),
        .busy_table_rd1_addr(busy_table_rd1_addr),
        .busy_table_data1_in(busy_table_data1_in),
        .busy_table_rd2_addr(busy_table_rd2_addr),
        .busy_table_data2_in(busy_table_data2_in),
        .phy_rf_rs1_addr_out(phy_rf_rs1_addr_out),
        .phy_rf_rs1_data_in(phy_rf_rs1_data_in),
        .phy_rf_rs2_addr_out(phy_rf_rs2_addr_out),
        .phy_rf_rs2_data_in(phy_rf_rs2_data_in),
        .res_st_wr_en_out(res_st_wr_en_out),
        .res_st_wr_addr_out(res_st_wr_addr_out),
        .res_st_data_out(res_st_data_out),
        .rob_tail_ptr(rob_tail_ptr),
        .rob_incr_tail_ptr(rob_incr_tail_ptr),
        .retire_en(retire_en),
        .retire_rob_addr(retire_rob_addr)
    );

    always #5   clk = ~clk;

    initial
    begin
        clk <= 1'b0;
        rst <= 1'b0;
        uop_in <= 'b0;
        busy_table_data1_in <= 1'b0;
        busy_table_data2_in <= 1'b0;
        phy_rf_rs1_data_in <= 'd2;
        phy_rf_rs2_data_in <= 'd4;
        rob_tail_ptr <= 'd0;
        retire_en <= 1'b0;
        retire_rob_addr <= 'd0;

        @(posedge clk);
        rst <= 1'b1;

        @(posedge clk);
        rst <= 1'b0;
        uop_in.uop_ic.optype <= 3'b011;
        uop_in.uop_ic.rd_valid <= 1'b1;
        uop_in.uop_ic.rs1_valid <= 1'b1;
        uop_in.uop_ic.rs2_valid <= 1'b1;
        uop_in.uop_ic.rd <= 'd4;
        uop_in.uop_ic.rs1 <= 'd8;
        uop_in.uop_ic.rs2 <= 'd12;

        @(posedge clk);
        uop_in.uop_ic.rd <= 'd16;
        phy_rf_rs1_data_in <= 'd5;
        phy_rf_rs2_data_in <= 'd6;
        uop_in.uop_ic.rs1 <= 'd20;
        uop_in.uop_ic.rs2 <= 'd24;
        rob_tail_ptr <= 'd1;

        @(posedge clk);
        phy_rf_rs1_data_in <= 'd5;
        uop_in.uop_ic.rd <= 'd20;
        uop_in.uop_ic.rs1 <= 'd16;
        busy_table_data1_in <= 1'b1;
        rob_tail_ptr <= 'd2;

        @(posedge clk);
        phy_rf_rs1_data_in <= 'd10;
        uop_in.uop_ic.rd <= 'd30;
        uop_in.uop_ic.rs1 <= 'd35;
        busy_table_data1_in <= 1'b0;
        rob_tail_ptr <= 'd3;

        @(posedge clk);
        uop_in.uop_ic.optype <= 3'b000;
        uop_in.uop_ic.rd_valid <= 1'b0;
        uop_in.uop_ic.rs1_valid <= 1'b0;
        uop_in.uop_ic.rs2_valid <= 1'b0;
        retire_en <= 1'b1;
        retire_rob_addr <= 'd2;

        @(posedge clk);
        retire_en <= 1'b0;
        retire_rob_addr <= 'd3;
        
        #100;
        $finish;
    end


endmodule
