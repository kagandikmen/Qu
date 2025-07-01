// Top front-end module of The Qu Processor
// Created:     2025-07-01
// Modified:    

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_FRONT
`define QU_FRONT

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module front_end
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

        // physical register file interface
        output  logic [$clog2(PHY_RF_DEPTH)-1:0] rf_rs1_addr,
        output  logic [$clog2(PHY_RF_DEPTH)-1:0] rf_rs2_addr,
        input   logic [31:0] rf_rs1_data_in,
        input   logic [31:0] rf_rs2_data_in,

        // reservation station interface
        output  logic res_st_wr_en_out,
        output  res_st_addr_t res_st_wr_addr_out,
        output  res_st_cell_t res_st_data_out
    );

    logic startup_ctrl_if_en_out;
    logic startup_ctrl_id_en_out;
    logic startup_ctrl_rn_en_out;

    logic fetch_branch_in;
    logic fetch_jump_in;
    logic fetch_exception_in;
    logic fetch_stall_in;
    logic [PC_WIDTH-1:0] fetch_pc_override_in;
    logic [INSTR_WIDTH-1:0] fetch_instr_out;
    logic [PC_WIDTH-1:0] fetch_pc_out;

    logic fifo_if_id_rd_en_in;
    logic [INSTR_WIDTH-1:0] fifo_if_id_data_out;
    logic fifo_if_id_wr_en_in;
    logic [INSTR_WIDTH-1:0] fifo_if_id_data_in;
    logic fifo_if_id_empty_out;
    logic fifo_if_id_full_out;

    logic [INSTR_WIDTH-1:0] decode_instr_in;
    logic decode_nop_out;
    logic decode_invalid_out;
    uop_t decode_uop_out;

    logic fifo_id_mp_rd_en_in;
    logic [(UOP_WIDTH+1)-1:0] fifo_id_mp_data_out;
    logic fifo_id_mp_wr_en_in;
    logic [(UOP_WIDTH+1)-1:0] fifo_id_mp_data_in;
    logic fifo_id_mp_empty_out;
    logic fifo_id_mp_full_out;

    uop_t map_uop_in;
    uop_t map_uop_out;
    logic map_full_out;
    logic map_busy_table_wr_en_out;
    logic [PHY_RF_ADDR_WIDTH-1:0] map_busy_table_wr_addr_out;
    logic map_busy_table_data_out;
    logic map_uop_data_in_proper;

    logic [PHY_RF_ADDR_WIDTH-1:0] busy_table_rd1_addr_in;
    logic busy_table_data1_out;
    logic [PHY_RF_ADDR_WIDTH-1:0] busy_table_rd2_addr_in;
    logic busy_table_data2_out;
    logic busy_table_wr_en_in;
    logic [PHY_RF_ADDR_WIDTH-1:0] busy_table_wr_addr_in;
    logic busy_table_data_in;

    logic fifo_mp_rn_rd_en_in;
    uop_t fifo_mp_rn_data_out;
    logic fifo_mp_rn_wr_en_in;
    uop_t fifo_mp_rn_data_in;
    logic fifo_mp_rn_empty_out;
    logic fifo_mp_rn_full_out;

    logic rename_en;
    uop_t rename_uop_in;
    logic [PHY_RF_ADDR_WIDTH-1:0] rename_busy_table_rd1_addr_out;
    logic rename_busy_table_data1_in;
    logic [PHY_RF_ADDR_WIDTH-1:0] rename_busy_table_rd2_addr_out;
    logic rename_busy_table_data2_in;
    logic [PHY_RF_ADDR_WIDTH-1:0] rename_phy_rf_rs1_addr_out;
    logic [31:0]rename_phy_rf_rs1_data_in;
    logic [PHY_RF_ADDR_WIDTH-1:0] rename_phy_rf_rs2_addr_out;
    logic [31:0]rename_phy_rf_rs2_data_in;

    startup_ctrl qu_startup_ctrl (
        .clk(clk),
        .rst(rst),
        .fifo_mp_rn_empty(fifo_mp_rn_empty_out),
        .if_en(startup_ctrl_if_en_out),
        .id_en(startup_ctrl_id_en_out),
        .rn_en(startup_ctrl_rn_en_out)
    );

    fetch #(
        .INSTR_WIDTH(INSTR_WIDTH),
        .PMEM_INIT_FILE(PMEM_INIT_FILE),
        .PC_WIDTH(PC_WIDTH),
        .PC_RESET_VAL(QU_PC_RESET_VAL)
    ) qu_fetch (
        .clk(clk),
        .rst(rst),
        .branch(fetch_branch_in),
        .jump(fetch_jump_in),
        .exception(fetch_exception_in),
        .stall(fetch_stall_in),
        .pc_override_in(fetch_pc_override_in),
        .instr(fetch_instr_out),
        .pc(fetch_pc_out)
    );

    fifo #(
        .FIFO_WIDTH(INSTR_WIDTH),
        .FIFO_DEPTH(4)
    ) qu_fifo_if_id (
        .clk(clk),
        .rst(rst),
        .rd_en(fifo_if_id_rd_en_in),
        .data_out(fifo_if_id_data_out),
        .wr_en(fifo_if_id_wr_en_in),
        .data_in(fifo_if_id_data_in),
        .empty(fifo_if_id_empty_out),
        .almost_empty(),
        .full(fifo_if_id_full_out),
        .almost_full()
    );

    decode #(
        .INSTR_WIDTH(INSTR_WIDTH)
    ) qu_decode (
        .instr_in(decode_instr_in),
        .nop(decode_nop_out),
        .invalid(decode_invalid_out),
        .uop_out(decode_uop_out)
    );

    fifo #(
        .FIFO_WIDTH(UOP_WIDTH+1),
        .FIFO_DEPTH(4)
    ) qu_fifo_id_mp (
        .clk(clk),
        .rst(rst),
        .rd_en(fifo_id_mp_rd_en_in),
        .data_out(fifo_id_mp_data_out),
        .wr_en(fifo_id_mp_wr_en_in),
        .data_in(fifo_id_mp_data_in),
        .empty(fifo_id_mp_empty_out),
        .almost_empty(),
        .full(fifo_id_mp_full_out),
        .almost_full()
    );

    map #(
        .LOG_RF_DEPTH(LOG_RF_DEPTH),
        .PHY_RF_DEPTH(PHY_RF_DEPTH)
    ) qu_map (
        .clk(clk),
        .rst(rst),
        .en(map_en),
        .uop_in(map_uop_in),
        .uop_out(map_uop_out),
        .full(map_full_out),
        .busy_table_wr_en(map_busy_table_wr_en_out),
        .busy_table_wr_addr(map_busy_table_wr_addr_out),
        .busy_table_data_out(map_busy_table_data_out)
    );
    
    busy_table #(
        .PHY_RF_DEPTH(PHY_RF_DEPTH)
    ) qu_busy_table (
        .clk(clk),
        .rst(rst),
        .rd1_addr(busy_table_rd1_addr_in),        
        .data1_out(busy_table_data1_out),       
        .rd2_addr(busy_table_rd2_addr_in),        
        .data2_out(busy_table_data2_out),       
        .wr_en(busy_table_wr_en_in),
        .wr_addr(busy_table_wr_addr_in),
        .data_in(busy_table_data_in)
    );

    fifo #(
        .FIFO_WIDTH(UOP_WIDTH),
        .FIFO_DEPTH(4)
    ) qu_fifo_mp_rn (
        .clk(clk),
        .rst(rst),
        .rd_en(fifo_mp_rn_rd_en_in),
        .data_out(fifo_mp_rn_data_out),
        .wr_en(fifo_mp_rn_wr_en_in),
        .data_in(fifo_mp_rn_data_in),
        .empty(fifo_mp_rn_empty_out),
        .almost_empty(),
        .full(fifo_mp_rn_full_out),
        .almost_full()
    );

    rename #() qu_rename (
        .clk(clk),
        .rst(rst),
        .en(rename_en),
        .uop_in(rename_uop_in),
        .busy_table_rd1_addr(rename_busy_table_rd1_addr_out),
        .busy_table_data1_in(rename_busy_table_data1_in),
        .busy_table_rd2_addr(rename_busy_table_rd2_addr_out),
        .busy_table_data2_in(rename_busy_table_data2_in),
        .phy_rf_rs1_addr_out(rename_phy_rf_rs1_addr_out),
        .phy_rf_rs1_data_in(rename_phy_rf_rs1_data_in),
        .phy_rf_rs2_addr_out(rename_phy_rf_rs2_addr_out),
        .phy_rf_rs2_data_in(rename_phy_rf_rs2_data_in),
        .res_st_wr_en_out(res_st_wr_en_out),
        .res_st_wr_addr_out(res_st_wr_addr_out),
        .res_st_data_out(res_st_data_out)
    );

    assign rf_rs1_addr = rename_phy_rf_rs1_addr_out;
    assign rf_rs2_addr = rename_phy_rf_rs2_addr_out;

    assign fetch_branch_in = branch;
    assign fetch_jump_in = jump;
    assign fetch_exception_in = exception;
    assign fetch_stall_in = stall || if_stall || fifo_if_id_full_out;
    assign fetch_pc_override_in = pc_override;
    
    assign fifo_if_id_rd_en_in = !stall && !id_stall && !fifo_if_id_empty_out && startup_ctrl_id_en_out;
    assign fifo_if_id_wr_en_in = !fetch_stall_in && startup_ctrl_if_en_out;
    assign fifo_if_id_data_in = fetch_instr_out;
    
    assign decode_instr_in = fifo_if_id_data_out;
    assign decode_proper_out = !decode_invalid_out && !decode_nop_out;

    assign fifo_id_mp_rd_en_in = !stall && !fifo_id_mp_empty_out;
    assign fifo_id_mp_wr_en_in = !stall;
    assign fifo_id_mp_data_in = {decode_proper_out, decode_uop_out};

    assign map_uop_data_in_proper = fifo_id_mp_data_out[UOP_WIDTH];
    assign map_en = !mp_stall && map_uop_data_in_proper && !rst;
    assign map_uop_in = fifo_id_mp_data_out[UOP_WIDTH-1:0];

    assign busy_table_rd1_addr_in = rename_busy_table_rd1_addr_out;
    assign busy_table_rd2_addr_in = rename_busy_table_rd2_addr_out;
    assign busy_table_wr_en_in = map_busy_table_wr_en_out;
    assign busy_table_wr_addr_in = map_busy_table_wr_addr_out;
    assign busy_table_data_in = map_busy_table_data_out;

    assign fifo_mp_rn_rd_en_in = !fifo_mp_rn_empty_out;
    assign fifo_mp_rn_wr_en_in = busy_table_wr_en_in;   // whatever is enabling wr_en of busy table should enable the fifo too
    assign fifo_mp_rn_data_in = map_uop_out;

    assign rename_en = startup_ctrl_rn_en_out;
    assign rename_uop_in = fifo_mp_rn_data_out;
    assign rename_busy_table_data1_in = busy_table_data1_out;
    assign rename_busy_table_data2_in = busy_table_data2_out;
    assign rename_phy_rf_rs1_data_in = rf_rs1_data_in;
    assign rename_phy_rf_rs2_data_in = rf_rs2_data_in;

endmodule

`endif
