// Retire stage of The Qu Processor
// Created:     2025-07-06
// Modified:    2025-07-07

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_RETIRE
`define QU_RETIRE

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module retire 
    #()(
        input   logic clk,
        input   logic rst,

        // FIFO interface
        input   phy_rf_data_t value_in,
        input   res_st_cell_t op_in,

        // register file interface
        output  logic phy_rf_wr_en,
        output  phy_rf_addr_t phy_rf_wr_addr,
        output  phy_rf_data_t phy_rf_wr_data,

        // rename stage interface
        output  logic busy_table_wr_en,
        output  logic [PHY_RF_ADDR_WIDTH-1:0] busy_table_wr_addr,
        output  logic busy_table_wr_data,
        output  rob_addr_t rob_tail_ptr,
        input   logic rob_incr_tail_ptr,
        output  logic rob_full,

        // reservation station interface
        output  logic res_st_retire_en,
        output  rob_addr_t res_st_retire_rob_addr,
        output  phy_rf_data_t res_st_retire_value
    );

    rob_addr_t head_ptr;
    rob_addr_t tail_ptr;

    logic [$bits(rob_addr_t):0] head_ptr_padded;
    logic [$bits(rob_addr_t):0] tail_ptr_padded;

    logic rob_wr1_en;
    rob_addr_t rob_wr1_addr;
    rob_cell_t rob_wr1_in;

    logic rob_wr2_en;
    rob_addr_t rob_wr2_addr;
    rob_cell_t rob_wr2_in;

    rob_addr_t rob_rd1_addr;
    rob_cell_t rob_rd1_out;

    rob_addr_t rob_rd2_addr;
    rob_cell_t rob_rd2_out;

    logic op_in_valid;

    logic res_st_retire_en_buf;

    assign op_in_valid = op_in.op[0];

    assign head_ptr_padded[$bits(rob_addr_t)] = 1'b0;
    assign head_ptr_padded[$bits(rob_addr_t)-1:0] = head_ptr;
    assign tail_ptr_padded[$bits(rob_addr_t)] = 1'b0;
    assign tail_ptr_padded[$bits(rob_addr_t)-1:0] = tail_ptr;

    assign rob_wr1_en = op_in_valid;
    assign rob_wr1_addr = op_in.rob_addr;
    assign rob_wr1_in.value = value_in;
    assign rob_wr1_in.dest = op_in.dest;
    assign rob_wr1_in.state = ROB_STATE_PENDING;

    assign rob_tail_ptr = tail_ptr;
    assign res_st_retire_en = res_st_retire_en_buf;
    assign rob_full = (tail_ptr_padded + 1 == head_ptr_padded);

    rob qu_rob (
        .clk(clk),
        .rst(rst),
        .wr1_en(rob_wr1_en),
        .wr1_addr(rob_wr1_addr),
        .wr1_in(rob_wr1_in),
        .wr2_en(rob_wr2_en),
        .wr2_addr(rob_wr2_addr),
        .wr2_in(rob_wr2_in),
        .rd1_addr(rob_rd1_addr),
        .rd1_out(rob_rd1_out),
        .rd2_addr(rob_rd2_addr),
        .rd2_out(rob_rd2_out)
    );

    always_ff @(posedge clk)
    begin
        if(rob_incr_tail_ptr)
        begin
            tail_ptr <= (tail_ptr == ROB_DEPTH-1) ? 'd1 : tail_ptr + 1;
        end

        if(res_st_retire_en_buf)
        begin
            head_ptr <= (head_ptr == ROB_DEPTH-1) ? 'd1 : head_ptr + 1;
        end

        if(rst)
        begin
            head_ptr <= 'd1;
            tail_ptr <= 'd1;
        end
    end

    always_comb
    begin
        rob_rd1_addr = head_ptr;

        phy_rf_wr_en = rob_rd1_out.state[1] && rob_rd1_out.state[0];
        phy_rf_wr_addr = rob_rd1_out.dest;
        phy_rf_wr_data = rob_rd1_out.value;

        busy_table_wr_en = rob_rd1_out.state[1] && rob_rd1_out.state[0];
        busy_table_wr_addr = rob_rd1_out.dest;
        busy_table_wr_data = 1'b0;

        res_st_retire_en_buf = rob_rd1_out.state[1] && rob_rd1_out.state[0];
        res_st_retire_rob_addr = head_ptr;
        res_st_retire_value = rob_rd1_out.value;

        rob_wr2_en = rob_rd1_out.state[1] && rob_rd1_out.state[0];
        rob_wr2_addr = head_ptr;
        rob_wr2_in = rob_rd1_out;
        rob_wr2_in.state = ROB_STATE_RETIRED;
    end

endmodule

`endif
