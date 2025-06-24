// PC Counter Testbench
// Created:     2025-06-23
// Modified:    2025-06-24

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`timescale 1ns/1ps

module tb_pc_ctr
    #()();

    localparam PC_WIDTH = 32;
    localparam PC_INC = 1;
    localparam PC_RESET_VAL = 0;

    logic clk;
    logic rst;
    logic en;

    logic pc_override;
    logic [PC_WIDTH-1:0] pc_in;

    logic [PC_WIDTH-1:0] pc_out;

    pc_ctr #(.PC_WIDTH(PC_WIDTH), .PC_INC(PC_INC), .PC_RESET_VAL(PC_RESET_VAL))
    dut
    (
        .clk(clk),
        .rst(rst),
        .en(en),
        .pc_override(pc_override),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    always #5   clk = ~clk;

    initial
    begin
        clk <= 1'b0;
        rst <= 1'b0;
        en <= 1'b1;
        pc_override <= 1'b0;
        pc_in <= 1'b0;

        repeat(2) @(posedge clk);
        rst <= 1'b1;

        repeat(2) @(posedge clk);
        rst <= 1'b0;

        repeat(10) @(posedge clk);
        pc_override <= 1'b1;
        pc_in <= 'd15;

        @(posedge clk);
        pc_override <= 1'b0;

        repeat(10) @(posedge clk);
        rst <= 1'b1;

        repeat(3) @(posedge clk);
        rst <= 1'b0;

        repeat(3) @(posedge clk);
        en <= 1'b0;

        repeat(3) @(posedge clk);
        en <= 1'b1;

        repeat(10) @(posedge clk);
        $finish;
    end

endmodule
