// Fetch stage testbench
// Created:     2025-06-24
// Modified:    2025-07-14

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`timescale 1ns/1ps

`include "../lib/qu_common.svh"

import qu_common::*;

module tb_fetch
    #()();

    localparam INSTR_WIDTH = 32;
    localparam PC_WIDTH = 12;
    localparam PC_RESET_VAL = 0;

    logic clk;
    logic rst;

    logic branch;
    logic jump;
    logic exception;
    logic stall;
    
    pc_t pc_override_in;
    
    logic [INSTR_WIDTH-1:0] instr_in;
    logic [INSTR_WIDTH-1:0] instr_out;

    pc_t pc;
    pc_t next_pc;

    fetch #(
        .INSTR_WIDTH(INSTR_WIDTH),
        .PC_WIDTH(PC_WIDTH),
        .PC_RESET_VAL(PC_RESET_VAL)
    ) dut (
        .clk(clk),
        .rst(rst),
        .branch(branch),
        .jump(jump),
        .exception(exception),
        .stall(stall),
        .pc_override_in(pc_override_in),
        .instr_in(instr_in),
        .instr_out(instr_out),
        .pc(pc),
        .next_pc(next_pc)
    );

    always #5   clk = ~clk;

    initial
    begin
        clk <= 1'b0;
        rst <= 1'b0;
        branch <= 1'b0;
        jump <= 1'b0;
        exception <= 1'b0;
        stall <= 1'b0;
        pc_override_in <= 'd0;
        instr_in <= 'd0;

        @(posedge clk);
        rst <= 1'b1;

        repeat(2) @(posedge clk);
        rst <= 1'b0;
        instr_in <= get_encoding_r_instr(FUNCT3_ADD, 'd3, 'd4, 'd5);

        repeat(10) @(posedge clk);
        jump <= 1'b1;
        pc_override_in <= 'd50;

        @(posedge clk);
        jump <= 1'b0;

        repeat(10) @(posedge clk);
        stall <= 1'b1;

        repeat(2) @(posedge clk);
        stall <= 1'b0;

        repeat(10) @(posedge clk);
        $finish;
    end

endmodule
