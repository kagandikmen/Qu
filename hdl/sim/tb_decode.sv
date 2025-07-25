// Decode stage testbench
// Created:     2025-06-27
// Modified:    2025-07-13

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`timescale 1ns/1ps

`include "../lib/qu_common.svh"

import qu_common::*;

module tb_decode
    #()();

    localparam INSTR_WIDTH = 32;

    logic clk;

    logic [INSTR_WIDTH-1:0] instr_in;
    pc_t pc_in;

    logic nop;
    logic invalid;
    uop_t uop_out;

    decode #(
        .INSTR_WIDTH(INSTR_WIDTH)
    ) dut (
        .instr_in(instr_in),
        .pc_in(pc_in),
        .nop(nop),
        .invalid(invalid),
        .uop_out(uop_out)
    );

    always #5   clk = ~clk;

    initial
    begin

        clk <= 1'b0;
        pc_in <= 'd0;
        instr_in <= 32'b0;

        @(posedge clk);
        pc_in <= 'd0;
        instr_in <= get_encoding_r_instr(FUNCT3_ADD, 'd1, 'd1, 'd1);

        @(posedge clk);
        pc_in <= 'd4;
        instr_in <= get_encoding_r_instr(FUNCT3_ADD, 'd0, 'd1, 'd1);

        @(posedge clk);
        pc_in <= 'd8;
        instr_in <= get_encoding_b_instr(FUNCT3_BEQ, 'd0, 'd0, 'd0);

        @(posedge clk);
        pc_in <= 'd12;
        instr_in <= 32'hFFFF_FFFF;

        repeat(10) @(posedge clk);
        $finish;
    end

endmodule