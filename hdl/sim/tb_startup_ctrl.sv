// Startup Controller Testbench
// Created:     2025-06-27
// Modified:    2025-07-04

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`timescale 1ns/1ps

module tb_startup_ctrl
    #()();

    logic clk;
    logic rst;

    logic if_en;
    logic id_en;

    startup_ctrl dut (
        .clk(clk),
        .rst(rst),
        .if_en(if_en),
        .id_en(id_en)
    );

    always #5   clk = ~clk;

    initial
    begin
        clk <= 1'b0;
        rst <= 1'b0;

        @(posedge clk);
        rst <= 1'b1;

        repeat(5) @(posedge clk);
        rst <= 1'b0;

        repeat(5) @(posedge clk);
        rst <= 1'b1;

        @(posedge clk);
        rst <= 1'b0;

        #200;
        $finish;
    end
endmodule
