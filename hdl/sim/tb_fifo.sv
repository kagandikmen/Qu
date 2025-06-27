// FIFO testbench
// Created:     2025-06-23
// Modified:    2025-06-27

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`timescale 1ns/1ps

module tb_fifo
    #()();

    localparam FIFO_WIDTH = 32;
    localparam FIFO_DEPTH = 8;

    logic clk;
    logic rst;

    logic rd_en;
    logic [FIFO_WIDTH-1:0] data_out;

    logic wr_en;
    logic [FIFO_WIDTH-1:0] data_in;

    logic empty;
    logic almost_empty;

    logic full;
    logic almost_full;

    fifo #(.FIFO_WIDTH(FIFO_WIDTH), .FIFO_DEPTH(FIFO_DEPTH))
    dut
    (
        .clk(clk),
        .rst(rst),
        .rd_en(rd_en),
        .data_out(data_out),
        .wr_en(wr_en),
        .data_in(data_in),
        .empty(empty),
        .almost_empty(almost_empty),
        .full(full),
        .almost_full(almost_full)
    );

    always #5   clk = ~clk;

    initial
    begin
        clk <= 1'b0;
        rst <= 1'b0;
        rd_en <= 1'b0;
        wr_en <= 1'b0;
        data_in <= 'b0;

        #5;
        rst <= 1'b1;

        @(posedge clk);
        @(posedge clk);
        rst <= 1'b0;
        wr_en <= 1'b1;
        data_in <= 'd10;

        @(posedge clk);
        data_in <= 'd20;

        @(posedge clk);
        wr_en <= 1'b0;

        @(posedge clk);
        rd_en <= 1'b1;
        
        repeat(10) @(posedge clk);
        rd_en <= 1'b0;
        wr_en <= 1'b1;
        data_in <= 'd3;

        repeat(10) @(posedge clk);
        wr_en <= 1'b0;

        repeat(10) @(posedge clk);
        $finish;
    end

endmodule
