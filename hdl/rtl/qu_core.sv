// The Qu Processor CPU core module
// Created:     2025-06-27
// Modified:    2025-07-01

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
        parameter PMEM_INIT_FILE = "",
        parameter INSTR_WIDTH = QU_INSTR_WIDTH,
        parameter PC_WIDTH = QU_PC_WIDTH
    )(
        input   logic clk,
        input   logic rst,
        
        input   logic branch,
        input   logic jump,
        input   logic exception,
        input   logic stall,
        input   logic [PC_WIDTH-1:0] pc_override,

        input   logic if_stall,
        input   logic id_stall,
        input   logic mp_stall,

        input   logic rf_wr_en,
        input   logic [PHY_RF_ADDR_WIDTH-1:0] rf_rd_addr,
        input   logic [31:0] rf_data_in,

        input   res_st_addr_t res_st_rd1_addr_in,
        output  res_st_cell_t res_st_rd1_out,
        input   res_st_addr_t res_st_rd2_addr_in,
        output  res_st_cell_t res_st_rd2_out
    );

    logic [PHY_RF_ADDR_WIDTH-1:0] front_end_rf_rs1_addr_out;
    logic [PHY_RF_ADDR_WIDTH-1:0] front_end_rf_rs2_addr_out;
    logic [31:0] front_end_rf_rs1_data_in;
    logic [31:0] front_end_rf_rs2_data_in;
    logic front_end_res_st_wr_en_out;
    res_st_addr_t front_end_res_st_wr_addr_out;
    res_st_cell_t front_end_res_st_data_out;

    logic res_st_wr_en_in;
    res_st_addr_t res_st_wr_addr_in;
    res_st_cell_t res_st_wr_in;

    logic [PHY_RF_ADDR_WIDTH-1:0] rf_rs1_addr_in;
    logic [PHY_RF_ADDR_WIDTH-1:0] rf_rs2_addr_in;
    logic [31:0] rf_rs1_data_out;
    logic [31:0] rf_rs2_data_out;

    assign front_end_rf_rs1_data_in = rf_rs1_data_out;
    assign front_end_rf_rs2_data_in = rf_rs2_data_out;

    assign res_st_wr_en_in = front_end_res_st_wr_en_out;
    assign res_st_wr_addr_in = front_end_res_st_wr_addr_out;
    assign res_st_wr_in = front_end_res_st_data_out;

    assign rf_rs1_addr_in = front_end_rf_rs1_addr_out;
    assign rf_rs2_addr_in = front_end_rf_rs2_addr_out;

    front_end #(
        .PMEM_INIT_FILE(PMEM_INIT_FILE),
        .INSTR_WIDTH(INSTR_WIDTH),
        .PC_WIDTH(PC_WIDTH)
    ) qu_front_end (
        .clk(clk),
        .rst(rst),
        .branch(branch),
        .jump(jump),
        .exception(exception),
        .stall(stall),
        .pc_override(pc_override),
        .if_stall(if_stall),
        .id_stall(id_stall),
        .mp_stall(mp_stall),
        .rf_rs1_addr(front_end_rf_rs1_addr_out),
        .rf_rs2_addr(front_end_rf_rs2_addr_out),
        .rf_rs1_data_in(front_end_rf_rs1_data_in),
        .rf_rs2_data_in(front_end_rf_rs2_data_in),
        .res_st_wr_en_out(front_end_res_st_wr_en_out),
        .res_st_wr_addr_out(front_end_res_st_wr_addr_out),
        .res_st_data_out(front_end_res_st_data_out)
    );

    res_st #(
        .RES_ST_DEPTH(RES_ST_DEPTH)
    ) qu_res_st (
        .clk(clk),
        .rst(rst),
        .wr_en(res_st_wr_en_in),
        .wr_addr(res_st_wr_addr_in),
        .wr_in(res_st_wr_in),
        .rd1_addr(res_st_rd1_addr_in),
        .rd1_out(res_st_rd1_out),
        .rd2_addr(res_st_rd2_addr_in),
        .rd2_out(res_st_rd2_out)
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

    // TODO: Add back-end here when it is ready

endmodule

`endif
