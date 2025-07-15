// Execute stage testbench
// Created:     2025-07-04
// Modified:    2025-07-15

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`timescale 1ns/1ps

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module tb_execute
    #()();

    res_st_cell_t op1_in;
    res_st_cell_t op2_in;
    logic [31:0] value1_out;
    logic [31:0] value2_out;
    logic comp_result;
    res_st_cell_t op1_out;
    res_st_cell_t op2_out;

    execute dut (
        .op1_in(op1_in),
        .op2_in(op2_in),
        .value1_out(value1_out),
        .value2_out(value2_out),
        .comp_result(comp_result),
        .op1_out(op1_out),
        .op2_out(op2_out)
    );

    initial
    begin
        op1_in.busy <= 1'b1;
        op1_in.op <= 14'b0;
        op1_in.qj <= 'b0;
        op1_in.qk <= 'b0;
        op1_in.vj <= 'd5;
        op1_in.vk <= 'd10;
        op1_in.a <= 'b0;

        op2_in <= 'b0;

        #5;
        op1_in.busy <= 1'b1;
        op1_in.op <= 14'b01111000000000;
        op1_in.qj <= 'b0;
        op1_in.qk <= 'b0;
        op1_in.vj <= 'd20;
        op1_in.vk <= 'd10;
        op1_in.a <= 'b0;

        #100;
        $finish;
    end

endmodule
