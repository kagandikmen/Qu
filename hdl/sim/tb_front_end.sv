// Testbench for the top front-end module of The Qu Processor
// Created:     2025-07-01
// Modified:    2025-07-15

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`timescale 1ns/1ps

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module tb_front_end
    #()();

    localparam INSTR_WIDTH = QU_INSTR_WIDTH;
    localparam PC_WIDTH = QU_PC_WIDTH;
    localparam FIFO_IF_ID_DEPTH = 16;
    localparam FIFO_ID_MP_DEPTH = 16;
    localparam FIFO_MP_RN_DEPTH = 16;

    logic clk;
    logic rst;

    logic if_en;
    logic id_en;
    
    logic branch;
    logic jump;
    logic exception;
    logic stall;
    logic [PC_WIDTH-1:0] pc_override;

    logic if_stall;
    logic id_stall;
    logic mp_stall;
    logic rn_stall;

    pc_t next_pc;
    logic [INSTR_WIDTH-1:0] instr;

    logic busy_table_wr_en;
    logic [PHY_RF_ADDR_WIDTH-1:0] busy_table_wr_addr;
    logic busy_table_wr_data;
    logic retire_en;
    rob_addr_t retire_rob_addr;
    phy_rf_addr_t phyreg_renamed_free_reg_addr;
    rob_addr_t rob_tail_ptr;
    logic rob_incr_tail_ptr;
    logic rob_full;

    logic [$clog2(PHY_RF_DEPTH)-1:0] rf_rs1_addr;
    logic [$clog2(PHY_RF_DEPTH)-1:0] rf_rs2_addr;
    logic [31:0] rf_rs1_data_in = 'd0;
    logic [31:0] rf_rs2_data_in = 'd0;

    logic res_st_wr_en_out;
    res_st_addr_t res_st_wr_addr_out;
    res_st_cell_t res_st_data_out;

    front_end #(
        .INSTR_WIDTH(INSTR_WIDTH),
        .PC_WIDTH(PC_WIDTH),
        .FIFO_IF_ID_DEPTH(FIFO_IF_ID_DEPTH),
        .FIFO_ID_MP_DEPTH(FIFO_ID_MP_DEPTH),
        .FIFO_MP_RN_DEPTH(FIFO_MP_RN_DEPTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .if_en(if_en),
        .id_en(id_en),
        .branch(branch),
        .jump(jump),
        .exception(exception),
        .stall(stall),
        .pc_override(pc_override),
        .if_stall(if_stall),
        .id_stall(id_stall),
        .mp_stall(mp_stall),
        .rn_stall(rn_stall),
        .next_pc(next_pc),
        .instr(instr),
        .busy_table_wr_en(busy_table_wr_en),
        .busy_table_wr_addr(busy_table_wr_addr),
        .busy_table_wr_data(busy_table_wr_data),
        .retire_en(retire_en),
        .retire_rob_addr(retire_rob_addr),
        .phyreg_renamed_free_reg_addr(phyreg_renamed_free_reg_addr),
        .rob_tail_ptr(rob_tail_ptr),
        .rob_incr_tail_ptr(rob_incr_tail_ptr),
        .rob_full(rob_full),
        .rf_rs1_addr(rf_rs1_addr),
        .rf_rs2_addr(rf_rs2_addr),
        .rf_rs1_data_in(rf_rs1_data_in),
        .rf_rs2_data_in(rf_rs2_data_in),
        .res_st_wr_en_out(res_st_wr_en_out),
        .res_st_wr_addr_out(res_st_wr_addr_out),
        .res_st_data_out(res_st_data_out)
    );

    always #5   clk = ~clk;

    always_ff @(posedge clk)
    begin
        rf_rs1_data_in <= rf_rs1_data_in + 5;
        rf_rs2_data_in <= rf_rs2_data_in + 5;
    end

    initial
    begin
        clk <= 1'b0;
        rst <= 1'b0;
        if_en <= 1'b0;
        id_en <= 1'b0;
        branch <= 1'b0;
        jump <= 1'b0;
        exception <= 1'b0;
        stall <= 1'b0;
        pc_override <= 'd0;
        if_stall <= 1'b0;
        id_stall <= 1'b0;
        mp_stall <= 1'b0;
        rn_stall <= 1'b0;
        instr <= 'd0;
        busy_table_wr_en <= 1'b0;
        busy_table_wr_addr <= 'd0;
        busy_table_wr_data <= 1'b0;
        retire_en <= 1'b0;
        retire_rob_addr <= 'd0;
        phyreg_renamed_free_reg_addr <= 'd0;
        rob_tail_ptr <= 'd1;
        rob_full <= 1'b0;

        @(posedge clk);
        rst <= 1'b1;

        repeat(5) @(posedge clk);
        rst <= 1'b0;

        @(posedge clk);
        if_en <= 1'b1;
        instr <= get_encoding_r_instr(FUNCT3_ADD, 'd3, 'd4, 'd5);

        @(posedge clk);
        instr <= get_encoding_i_instr(FUNCT3_ADDI, 'd4, 'd3, 'd20);
        id_en <= 1'b1;

        @(posedge clk);
        instr <= 'b0;
        
        repeat(10) @(posedge clk);
        retire_en <= 1'b1;
        retire_rob_addr <= 'd1;

        @(posedge clk);
        retire_en <= 1'b0;

        #200;
        $finish;
    end
endmodule
