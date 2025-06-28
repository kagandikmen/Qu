// The Qu Processor CPU core testbench
// Created:     2025-06-27
// Modified:    2025-06-28

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`timescale 1ns/1ps

import qu_common::*;
import qu_uop::*;

module tb_qu_core
    #(
        parameter PMEM_INIT_FILE = "test.hex"
    )();

    localparam INSTR_WIDTH = QU_INSTR_WIDTH;
    localparam PC_WIDTH = QU_PC_WIDTH;

    logic clk;
    logic rst;
    
    logic branch;
    logic jump;
    logic exception;
    logic stall;
    logic [PC_WIDTH-1:0] pc_override;

    logic if_stall;
    logic id_stall;

    logic nop;
    logic invalid;
    uop_t uop_out;

    qu_core #(
        .PMEM_INIT_FILE(PMEM_INIT_FILE),
        .INSTR_WIDTH(INSTR_WIDTH),
        .PC_WIDTH(PC_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .branch(branch),
        .jump(jump),
        .exception(exception),
        .stall(stall),
        .pc_override(pc_override),
        .if_stall(if_stall),
        .id_stall(id_stall),
        .nop(nop),
        .invalid(invalid),
        .uop_out(uop_out)
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
        pc_override <= 'd0;
        if_stall <= 1'b0;
        id_stall <= 1'b0;

        @(posedge clk);
        rst <= 1'b1;

        repeat(5) @(posedge clk);
        rst <= 1'b0;

        repeat(10) @(posedge clk);
        if_stall <= 1'b1;

        repeat(20) @(posedge clk);
        if_stall <= 1'b0;

        repeat(3) @(posedge clk);
        id_stall <= 1'b1;

        repeat(20) @(posedge clk);
        id_stall <= 1'b0;

        repeat(3) @(posedge clk);
        branch <= 1'b1;
        pc_override <= 'd4;

        @(posedge clk);
        branch <= 1'b0;
        pc_override <= 'd0;

        #200;
        $finish;
    end

endmodule
