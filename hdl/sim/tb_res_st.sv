// Testbench for the reservation station
// Created:     2025-06-30
// Modified:    2025-07-07

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`timescale 1ns/1ps

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module tb_res_st
    #()();

    localparam RES_ST_DEPTH = 32;

    logic clk;
    logic rst;

    logic wr_en;
    logic [$clog2(RES_ST_DEPTH)-1:0] wr_addr;
    res_st_cell_t wr_in;

    logic [$clog2(RES_ST_DEPTH)-1:0] rd1_addr;
    res_st_cell_t rd1_out;

    logic [$clog2(RES_ST_DEPTH)-1:0] rd2_addr;
    res_st_cell_t rd2_out;

    logic [$clog2(RES_ST_DEPTH)-1:0] rd3_addr;
    res_st_cell_t rd3_out;

    logic [$clog2(RES_ST_DEPTH)-1:0] rd4_addr;
    res_st_cell_t rd4_out;

    logic retire_en;
    rob_addr_t retire_addr;
    phy_rf_data_t retire_value;

    res_st #(
        .RES_ST_DEPTH(RES_ST_DEPTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .wr_addr(wr_addr),
        .wr_in(wr_in),
        .rd1_addr(rd1_addr),
        .rd1_out(rd1_out),
        .rd2_addr(rd2_addr),
        .rd2_out(rd2_out),
        .rd3_addr(rd3_addr),
        .rd3_out(rd3_out),
        .rd4_addr(rd4_addr),
        .rd4_out(rd4_out),
        .retire_en(retire_en),
        .retire_addr(retire_addr),
        .retire_value(retire_value)
    );

    always #5   clk = ~clk;

    initial
    begin
        clk <= 1'b0;
        rst <= 1'b0;
        wr_en <= 1'b0;
        wr_addr <= 'b0;
        wr_in <= 'b0;
        rd1_addr <= 'b0;
        rd2_addr <= 'b0;
        rd3_addr <= 'b0;
        rd4_addr <= 'b0;
        retire_en <= 1'b0;
        retire_addr <= 'd0;
        retire_value <= 'd0;

        @(posedge clk);
        rst <= 1'b1;

        repeat(5) @(posedge clk);
        rst <= 1'b0;
        wr_en <= 1'b1;
        wr_addr <= 'd2;
        wr_in.a <= 'd0;
        wr_in.vk <= 'd5;
        wr_in.vj <= 'd10;
        wr_in.qk <= 'd3;
        wr_in.qj <= 'd2;
        wr_in.op <= 'b0_1111_0000_1111;
        wr_in.busy <= 1'b1;

        @(posedge clk);
        wr_addr <= 'd3;
        wr_in.a <= 'd5;
        wr_in.vk <= 'd10;
        wr_in.vj <= 'd20;
        wr_in.qk <= 'd6;
        wr_in.qj <= 'd4;
        wr_in.op <= 'b0_0000_0000_1111;
        wr_in.busy <= 1'b0;

        @(posedge clk);
        wr_en <= 1'b0;
        rd1_addr <= 'd2;
        rd2_addr <= 'd3;

        @(posedge clk);
        rd1_addr <= 'd0;
        rd2_addr <= 'd0;
        rd3_addr <= 'd2;
        rd4_addr <= 'd3;

        @(posedge clk);
        retire_en <= 1'b1;
        retire_addr <= 'd2;
        retire_value <= 'd12;

        @(posedge clk);
        retire_en <= 1'b0;

        #100;
        $finish;
    end

endmodule
