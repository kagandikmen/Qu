// The Qu Processor CPU core testbench
// Created:     2025-06-27
// Modified:    2025-07-14

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`timescale 1ns/1ps

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module tb_qu_core
    #(
        parameter MEM_INIT_FILE = "test.hex"
    )();

    localparam INSTR_WIDTH = QU_INSTR_WIDTH;
    localparam PC_WIDTH = QU_PC_WIDTH;
    localparam FIFO_IF_ID_DEPTH = 16;
    localparam FIFO_ID_MP_DEPTH = 16;
    localparam FIFO_MP_RN_DEPTH = 16;
    
    logic clk;
    logic rst;
    
    logic stall;

    logic if_stall;
    logic id_stall;
    logic mp_stall;
    logic rn_stall;

    logic schedule_en;

    qu_core #(
        .MEM_INIT_FILE(MEM_INIT_FILE),
        .INSTR_WIDTH(INSTR_WIDTH),
        .PC_WIDTH(PC_WIDTH),
        .FIFO_IF_ID_DEPTH(FIFO_IF_ID_DEPTH),
        .FIFO_ID_MP_DEPTH(FIFO_ID_MP_DEPTH),
        .FIFO_MP_RN_DEPTH(FIFO_MP_RN_DEPTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .if_stall(if_stall),
        .id_stall(id_stall),
        .mp_stall(mp_stall),
        .rn_stall(rn_stall),
        .schedule_en(schedule_en)
    );

    always #5   clk = ~clk;

    initial
    begin
        clk <= 1'b0;
        rst <= 1'b0;
        stall <= 1'b0;
        if_stall <= 1'b0;
        id_stall <= 1'b0;
        mp_stall <= 1'b0;
        rn_stall <= 1'b0;
        schedule_en <= 1'b0;

        @(posedge clk);
        rst <= 1'b1;

        repeat(5) @(posedge clk);
        rst <= 1'b0;

        // repeat(4) @(posedge clk);
        // id_stall <= 1'b1;

        // repeat(4) @(posedge clk);
        // id_stall <= 1'b0;

        // repeat(4) @(posedge clk);
        // mp_stall <= 1'b1;

        // repeat(4) @(posedge clk);
        // mp_stall <= 1'b0;

        // repeat(4) @(posedge clk);
        // rn_stall <= 1'b1;

        // repeat(4) @(posedge clk);
        // rn_stall <= 1'b0;

        repeat(20) @(posedge clk);
        schedule_en <= 1'b1;

        #200;
        $finish;
    end

endmodule
