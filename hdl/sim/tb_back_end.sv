// Testbench for the top back-end module of The Qu Processor
// Created:     2025-07-03
// Modified:    2025-07-13

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`timescale 1ns/1ps

module tb_back_end
    #()();

    logic clk;
    logic rst;
    logic schedule_en;

    res_st_addr_t res_st_rd1_addr;
    res_st_cell_t res_st_rd1_in;
    res_st_addr_t res_st_rd2_addr;
    res_st_cell_t res_st_rd2_in;
    res_st_addr_t res_st_rd3_addr;
    res_st_cell_t res_st_rd3_in;
    res_st_addr_t res_st_rd4_addr;
    res_st_cell_t res_st_rd4_in;

    logic res_st_retire_en;
    rob_addr_t res_st_retire_rob_addr;
    phy_rf_data_t res_st_retire_value;

    logic phy_rf_wr_en;
    phy_rf_addr_t phy_rf_wr_addr;
    phy_rf_data_t phy_rf_wr_data;

    logic busy_table_wr_en;
    phy_rf_addr_t busy_table_wr_addr;
    logic busy_table_wr_data;

    rob_addr_t rob_tail_ptr;
    logic rob_incr_tail_ptr;
    logic rob_full;

    logic mispredicted_branch;
    pc_t pc_to_jump;

    back_end dut (
        .clk(clk),
        .rst(rst),
        .schedule_en(schedule_en),
        .res_st_rd1_addr(res_st_rd1_addr),
        .res_st_rd1_in(res_st_rd1_in),
        .res_st_rd2_addr(res_st_rd2_addr),
        .res_st_rd2_in(res_st_rd2_in),
        .res_st_rd3_addr(res_st_rd3_addr),
        .res_st_rd3_in(res_st_rd3_in),
        .res_st_rd4_addr(res_st_rd4_addr),
        .res_st_rd4_in(res_st_rd4_in),
        .res_st_retire_en(res_st_retire_en),
        .res_st_retire_rob_addr(res_st_retire_rob_addr),
        .res_st_retire_value(res_st_retire_value),
        .phy_rf_wr_en(phy_rf_wr_en),
        .phy_rf_wr_addr(phy_rf_wr_addr),
        .phy_rf_wr_data(phy_rf_wr_data),
        .busy_table_wr_en(busy_table_wr_en),
        .busy_table_wr_addr(busy_table_wr_addr),
        .busy_table_wr_data(busy_table_wr_data),
        .rob_tail_ptr(rob_tail_ptr),
        .rob_incr_tail_ptr(rob_incr_tail_ptr),
        .rob_full(rob_full),
        .mispredicted_branch(mispredicted_branch),
        .pc_to_jump(pc_to_jump)
    );

    always #5   clk = ~clk;

    initial
    begin
        clk <= 1'b0;
        rst <= 1'b0;
        schedule_en <= 1'b1;
        rob_incr_tail_ptr <= 1'b1;

        res_st_rd1_in.rob_addr <= 2'd0;
        res_st_rd1_in.dest <= 'd4;
        res_st_rd1_in.busy <= 1'b1;
        res_st_rd1_in.op <= 14'd1;
        res_st_rd1_in.qj <= 'd0;
        res_st_rd1_in.qk <= 'd0;
        res_st_rd1_in.vj <= 'd11;
        res_st_rd1_in.vk <= 'd12;
        res_st_rd1_in.a <= 'd0;

        res_st_rd2_in.rob_addr <= 2'd1;
        res_st_rd2_in.dest <= 'd5;
        res_st_rd2_in.busy <= 1'b1;
        res_st_rd2_in.op <= 14'd3;
        res_st_rd2_in.qj <= 'd0;
        res_st_rd2_in.qk <= 'd0;
        res_st_rd2_in.vj <= 'd21;
        res_st_rd2_in.vk <= 'd22;
        res_st_rd2_in.a <= 'd0;

        res_st_rd3_in.rob_addr <= 2'd2;
        res_st_rd3_in.dest <= 'd6;
        res_st_rd3_in.busy <= 1'b1;
        res_st_rd3_in.op <= 14'd5;
        res_st_rd3_in.qj <= 'd0;
        res_st_rd3_in.qk <= 'd0;
        res_st_rd3_in.vj <= 'd31;
        res_st_rd3_in.vk <= 'd32;
        res_st_rd3_in.a <= 'd0;

        res_st_rd4_in.rob_addr <= 2'd3;
        res_st_rd4_in.dest <= 'd7;
        res_st_rd4_in.busy <= 1'b1;
        res_st_rd4_in.op <= 14'd7;
        res_st_rd4_in.qj <= 'd0;
        res_st_rd4_in.qk <= 'd0;
        res_st_rd4_in.vj <= 'd41;
        res_st_rd4_in.vk <= 'd42;
        res_st_rd4_in.a <= 'd0;

        @(posedge clk);
        rst <= 1'b1;

        repeat(5) @(posedge clk);
        rst <= 1'b0;

        repeat(4) @(posedge clk);
        res_st_rd1_in.rob_addr <= 2'd0;
        res_st_rd1_in.dest <= 'd4;
        res_st_rd1_in.busy <= 1'b1;
        res_st_rd1_in.op <= 14'd1;
        res_st_rd1_in.qj <= 'd0;
        res_st_rd1_in.qk <= 'd0;
        res_st_rd1_in.vj <= 'd11;
        res_st_rd1_in.vk <= 'd12;
        res_st_rd1_in.a <= 'd0;

        res_st_rd2_in.rob_addr <= 2'd1;
        res_st_rd2_in.dest <= 'd5;
        res_st_rd2_in.busy <= 1'b1;
        res_st_rd2_in.op <= 14'd3;
        res_st_rd2_in.qj <= 'd1;
        res_st_rd2_in.qk <= 'd0;
        res_st_rd2_in.vj <= 'd21;
        res_st_rd2_in.vk <= 'd22;
        res_st_rd2_in.a <= 'd0;

        res_st_rd3_in.rob_addr <= 2'd2;
        res_st_rd3_in.dest <= 'd6;
        res_st_rd3_in.busy <= 1'b1;
        res_st_rd3_in.op <= 14'd5;
        res_st_rd3_in.qj <= 'd0;
        res_st_rd3_in.qk <= 'd0;
        res_st_rd3_in.vj <= 'd31;
        res_st_rd3_in.vk <= 'd32;
        res_st_rd3_in.a <= 'd0;

        res_st_rd4_in.rob_addr <= 2'd3;
        res_st_rd4_in.dest <= 'd7;
        res_st_rd4_in.busy <= 1'b1;
        res_st_rd4_in.op <= 14'd7;
        res_st_rd4_in.qj <= 'd0;
        res_st_rd4_in.qk <= 'd0;
        res_st_rd4_in.vj <= 'd41;
        res_st_rd4_in.vk <= 'd42;
        res_st_rd4_in.a <= 'd0;

        repeat(3) @(posedge clk);
        res_st_rd2_in.qj <= 'd0;

        repeat(10) @(posedge clk);
        schedule_en <= 1'b0;
        rob_incr_tail_ptr <= 1'b0;

        repeat(3) @(posedge clk);
        schedule_en <= 1'b1;
        rob_incr_tail_ptr <= 1'b1;

        repeat(3) @(posedge clk);
        schedule_en <= 1'b0;
        rob_incr_tail_ptr <= 1'b0;

        #100;
        $finish;
    end

endmodule
