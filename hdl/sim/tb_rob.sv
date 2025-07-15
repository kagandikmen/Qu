// Testbench of the reorder buffer
// Created:     2025-07-05
// Modified:    2025-07-15

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`timescale 1ns/1ps

`include "../lib/qu_common.svh"

import qu_common::*;

module tb_rob
    #()();

    logic clk;
    logic rst;

    logic wr1_en;
    rob_addr_t wr1_addr;
    rob_cell_t wr1_in;

    logic wr2_en;
    rob_addr_t wr2_addr;
    rob_cell_t wr2_in;

    logic wr3_en;
    rob_addr_t wr3_addr;
    rob_cell_t wr3_in;

    rob_addr_t rd1_addr;
    rob_cell_t rd1_out;

    rob_addr_t rd2_addr;
    rob_cell_t rd2_out;

    rob dut (
        .clk(clk),
        .rst(rst),
        .wr1_en(wr1_en),
        .wr1_addr(wr1_addr),
        .wr1_in(wr1_in),
        .wr2_en(wr2_en),
        .wr2_addr(wr2_addr),
        .wr2_in(wr2_in),
        .wr3_en(wr3_en),
        .wr3_addr(wr3_addr),
        .wr3_in(wr3_in),
        .rd1_addr(rd1_addr),
        .rd1_out(rd1_out),
        .rd2_addr(rd2_addr),
        .rd2_out(rd2_out)
    );

    always #5   clk = ~clk;

    initial
    begin
        clk <= 1'b0;
        rst <= 1'b0;
        wr1_en <= 1'b0;
        wr1_addr <= 'd0;
        wr1_in <= 'd0;
        wr2_en <= 1'b0;
        wr2_addr <= 'd0;
        wr2_in <= 'd0;
        wr3_en <= 1'b0;
        wr3_addr <= 'd0;
        wr3_in <= 'd0;
        rd1_addr <= 'd0;
        rd2_addr <= 'd0;

        @(posedge clk);
        rst <= 1'b1;

        @(posedge clk);
        rst <= 1'b0;

        @(posedge clk);
        wr1_en <= 1'b1;
        wr1_addr <= 'd0;
        wr1_in <= 'd5;

        @(posedge clk);
        wr1_en <= 1'b0;
        wr1_addr <= 'd0;
        wr1_in <= 'd5;
        wr2_en <= 1'b1;
        wr2_addr <= 'd1;
        wr2_in <= 'd6;

        @(posedge clk);
        wr1_en <= 1'b1;
        wr1_addr <= 'd2;
        wr1_in <= 'd7;
        wr2_en <= 1'b1;
        wr2_addr <= 'd2;
        wr2_in <= 'd7;

        @(posedge clk);
        wr1_en <= 1'b0;
        wr2_en <= 1'b0;
        rd1_addr <= 'd1;
        rd2_addr <= 'd2;

        @(posedge clk);
        wr1_en <= 1'b1;
        wr1_addr <= 'd2;
        wr1_in <= 'd7;

        @(posedge clk);
        wr1_en <= 1'b0;
        wr3_en <= 1'b1;
        wr3_addr <= 'd5;
        wr3_in <= 'd10;

        @(posedge clk);
        wr3_en <= 1'b0;

        #100;
        $finish;
    end

endmodule
