// Testbench for the busy table of The Qu Processor
// Created:     2025-07-05
// Modified:    

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`timescale 1ns/1ps

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module tb_busy_table
    #()();

    logic clk;
    logic rst;
    
    logic [$clog2(PHY_RF_DEPTH)-1:0] rd1_addr;
    logic rd1_out;

    logic [$clog2(PHY_RF_DEPTH)-1:0] rd2_addr;
    logic rd2_out;

    logic wr1_en;
    logic [$clog2(PHY_RF_DEPTH)-1:0] wr1_addr;
    logic wr1_in;

    logic wr2_en;
    logic [$clog2(PHY_RF_DEPTH)-1:0] wr2_addr;
    logic wr2_in;

    busy_table #(
        .PHY_RF_DEPTH(PHY_RF_DEPTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .rd1_addr(rd1_addr),
        .rd1_out(rd1_out),
        .rd2_addr(rd2_addr),
        .rd2_out(rd2_out),
        .wr1_en(wr1_en),
        .wr1_addr(wr1_addr),
        .wr1_in(wr1_in),
        .wr2_en(wr2_en),
        .wr2_addr(wr2_addr),
        .wr2_in(wr2_in)
    );

    always #5   clk = ~clk;

    initial
    begin
        clk <= 1'b0;
        rst <= 1'b0;
        rd1_addr <= 1'b0;
        rd2_addr <= 1'b0;
        wr1_en <= 1'b0;
        wr1_addr <= 'd0;
        wr1_in <= 1'b0;
        wr2_en <= 1'b0;
        wr2_addr <= 'd0;
        wr2_in <= 1'b0;

        @(posedge clk);
        rst <= 1'b1;

        @(posedge clk);
        rst <= 1'b0;
        wr1_en <= 1'b1;
        wr1_addr <= 'd1;
        wr1_in <= 1'b1;

        @(posedge clk);
        wr1_en <= 1'b0;
        wr2_en <= 1'b1;
        wr2_addr <= 'd2;
        wr2_in <= 1'b1;

        @(posedge clk);
        wr1_en <= 1'b1;
        wr2_en <= 1'b1;
        wr1_addr <= 'd3;
        wr2_addr <= 'd4;
        wr1_in <= 1'b1;
        wr2_in <= 1'b1;

        @(posedge clk);
        wr1_en <= 1'b1;
        wr2_en <= 1'b1;
        wr1_addr <= 'd5;
        wr2_addr <= 'd5;
        wr1_in <= 1'b1;
        wr2_in <= 1'b1;

        @(posedge clk);
        wr1_en <= 1'b1;
        wr2_en <= 1'b1;
        wr1_addr <= 'd6;
        wr2_addr <= 'd6;
        wr1_in <= 1'b0;
        wr2_in <= 1'b1;

        @(posedge clk);
        wr1_en <= 1'b0;
        wr2_en <= 1'b0;
        rd1_addr <= 'd2;
        rd2_addr <= 'd2;

        @(posedge clk);
        rd1_addr <= 'd3;
        rd2_addr <= 'd11;

        @(posedge clk);
        rd1_addr <= 'd11;
        rd2_addr <= 'd3;

        #100;
        $finish;
    end

endmodule
