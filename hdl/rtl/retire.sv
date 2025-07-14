// Retire stage of The Qu Processor
// Created:     2025-07-06
// Modified:    2025-07-14

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
        input   logic comp_result_in,
        input   res_st_cell_t op_in,

        // register file interface
        output  logic phy_rf_wr_en,
        output  phy_rf_addr_t phy_rf_wr_addr,
        output  phy_rf_data_t phy_rf_wr_data,

        // map stage interface
        output  phy_rf_addr_t phyreg_renamed_free_reg_addr,

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
        output  phy_rf_data_t res_st_retire_value,

        // mispredicted branch
        output  logic mispredicted_branch,
        output  pc_t pc_to_jump,

        output  logic dmem_wr_en_out,
        output  logic dmem_rd_en_out,
        output  logic [31:0] dmem_addr_out,
        output  logic [31:0] dmem_data_out
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
    logic dmem_wr_en_out_buf;
    logic dmem_rd_en_out_buf;
    logic [31:0] dmem_addr_out_buf;
    logic [31:0] dmem_data_out_buf;

    phy_rf_addr_t phyreg_renamed_free_reg_addr_buf;

    assign op_in_valid = op_in.op.optype[0];

    assign head_ptr_padded[$bits(rob_addr_t)] = 1'b0;
    assign head_ptr_padded[$bits(rob_addr_t)-1:0] = head_ptr;
    assign tail_ptr_padded[$bits(rob_addr_t)] = 1'b0;
    assign tail_ptr_padded[$bits(rob_addr_t)-1:0] = tail_ptr;

    assign rob_wr1_en = op_in_valid;
    assign rob_wr1_addr = op_in.rob_addr;
    assign rob_wr1_in.value = (op_in.op.optype == OPTYPE_STORE) ? op_in.vk : value_in;

    // Currently, all branches are assumed not taken. This will be improved later.
    assign rob_wr1_in.mispredicted_branch = (op_in.op.optype == OPTYPE_BRANCH) && comp_result_in;
    
    assign rob_wr1_in.phyreg_old = op_in.phyreg_old;
    assign rob_wr1_in.store = (op_in.op.optype == OPTYPE_STORE);
    assign rob_wr1_in.load = (op_in.op.optype == OPTYPE_LOAD);
    assign rob_wr1_in.dest = (op_in.op.optype == OPTYPE_STORE) ? value_in : {'b0, op_in.dest};
    assign rob_wr1_in.state = ROB_STATE_PENDING;

    assign rob_tail_ptr = tail_ptr;
    assign res_st_retire_en = res_st_retire_en_buf;
    assign rob_full = (tail_ptr_padded + 1 == head_ptr_padded);

    assign dmem_wr_en_out = dmem_wr_en_out_buf;
    assign dmem_rd_en_out = dmem_rd_en_out_buf;
    assign dmem_addr_out = dmem_addr_out_buf;
    assign dmem_data_out = dmem_data_out_buf;

    assign phyreg_renamed_free_reg_addr = phyreg_renamed_free_reg_addr_buf;

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

        mispredicted_branch = rob_rd1_out.mispredicted_branch;
        pc_to_jump = rob_rd1_out.value;

        dmem_wr_en_out_buf = rob_rd1_out.store;
        dmem_rd_en_out_buf = rob_rd1_out.load;
        dmem_addr_out_buf = rob_rd1_out.store ? rob_rd1_out.dest.dmem_dest : rob_rd1_out.value;
        dmem_data_out_buf = rob_rd1_out.value;
        
        phy_rf_wr_en = (rob_rd1_out.state == ROB_STATE_PENDING && rob_rd1_out.dest != 'd0);
        phy_rf_wr_addr = rob_rd1_out.dest.phy_rf_padded_dest.dest;
        phy_rf_wr_data = rob_rd1_out.value;

        busy_table_wr_en = (rob_rd1_out.state == ROB_STATE_PENDING && rob_rd1_out.dest != 'd0);
        busy_table_wr_addr = rob_rd1_out.dest.phy_rf_padded_dest.dest;
        busy_table_wr_data = 1'b0;

        phyreg_renamed_free_reg_addr_buf = rob_rd1_out.phyreg_old;

        res_st_retire_en_buf = (rob_rd1_out.state == ROB_STATE_PENDING && rob_rd1_out.dest != 'd0);
        res_st_retire_rob_addr = head_ptr;
        res_st_retire_value = rob_rd1_out.value;

        rob_wr2_en = (rob_rd1_out.state == ROB_STATE_PENDING);
        rob_wr2_addr = head_ptr;
        rob_wr2_in = rob_rd1_out;
        rob_wr2_in.state = ROB_STATE_RETIRED;
    end

endmodule

`endif
