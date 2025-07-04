// Testbench for the top back-end module of The Qu Processor
// Created:     2025-07-03
// Modified:    2025-07-04

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

    logic [31:0] value_out;
    res_st_cell_t op_out;

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
        .value_out(value_out),
        .op_out(op_out)
    );

    always #5   clk = ~clk;

    initial
    begin
        clk <= 1'b0;
        rst <= 1'b0;
        schedule_en <= 1'b1;

        res_st_rd1_in.busy <= 1'b1;
        res_st_rd1_in.op <= 14'd1;
        res_st_rd1_in.qj <= 'd0;
        res_st_rd1_in.qk <= 'd0;
        res_st_rd1_in.vj <= 'd11;
        res_st_rd1_in.vk <= 'd12;
        res_st_rd1_in.a <= 'd0;

        res_st_rd2_in.busy <= 1'b1;
        res_st_rd2_in.op <= 14'd2;
        res_st_rd2_in.qj <= 'd0;
        res_st_rd2_in.qk <= 'd0;
        res_st_rd2_in.vj <= 'd21;
        res_st_rd2_in.vk <= 'd22;
        res_st_rd2_in.a <= 'd0;

        res_st_rd3_in.busy <= 1'b1;
        res_st_rd3_in.op <= 14'd3;
        res_st_rd3_in.qj <= 'd0;
        res_st_rd3_in.qk <= 'd0;
        res_st_rd3_in.vj <= 'd31;
        res_st_rd3_in.vk <= 'd32;
        res_st_rd3_in.a <= 'd0;

        res_st_rd4_in.busy <= 1'b1;
        res_st_rd4_in.op <= 14'd4;
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
        res_st_rd1_in.busy <= 1'b1;
        res_st_rd1_in.op <= 14'd1;
        res_st_rd1_in.qj <= 'd0;
        res_st_rd1_in.qk <= 'd0;
        res_st_rd1_in.vj <= 'd11;
        res_st_rd1_in.vk <= 'd12;
        res_st_rd1_in.a <= 'd0;

        res_st_rd2_in.busy <= 1'b1;
        res_st_rd2_in.op <= 14'd2;
        res_st_rd2_in.qj <= 'd1;
        res_st_rd2_in.qk <= 'd0;
        res_st_rd2_in.vj <= 'd21;
        res_st_rd2_in.vk <= 'd22;
        res_st_rd2_in.a <= 'd0;

        res_st_rd3_in.busy <= 1'b1;
        res_st_rd3_in.op <= 14'd3;
        res_st_rd3_in.qj <= 'd0;
        res_st_rd3_in.qk <= 'd0;
        res_st_rd3_in.vj <= 'd31;
        res_st_rd3_in.vk <= 'd32;
        res_st_rd3_in.a <= 'd0;

        res_st_rd4_in.busy <= 1'b1;
        res_st_rd4_in.op <= 14'd4;
        res_st_rd4_in.qj <= 'd0;
        res_st_rd4_in.qk <= 'd0;
        res_st_rd4_in.vj <= 'd41;
        res_st_rd4_in.vk <= 'd42;
        res_st_rd4_in.a <= 'd0;

        repeat(3) @(posedge clk);
        res_st_rd2_in.qj <= 'd0;

        repeat(10) @(posedge clk);
        schedule_en <= 1'b0;

        repeat(3) @(posedge clk);
        schedule_en <= 1'b1;

        repeat(3) @(posedge clk);
        schedule_en <= 1'b0;

        #100;
        $finish;
    end

endmodule
