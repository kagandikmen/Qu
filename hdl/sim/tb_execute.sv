// Execute stage testbench
// Created:     2025-07-04
// Modified:    

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

    res_st_cell_t op_in;
    logic [31:0] value_out;
    res_st_cell_t op_out;

    execute dut (
        .op_in(op_in),
        .value_out(value_out),
        .op_out(op_out)
    );

    initial
    begin
        op_in.busy <= 1'b1;
        op_in.op <= 14'b0;
        op_in.qj <= 'b0;
        op_in.qk <= 'b0;
        op_in.vj <= 'd5;
        op_in.vk <= 'd10;
        op_in.a <= 'b0;

        #5;
        op_in.busy <= 1'b1;
        op_in.op <= 14'b01111000000000;
        op_in.qj <= 'b0;
        op_in.qk <= 'b0;
        op_in.vj <= 'd20;
        op_in.vk <= 'd10;
        op_in.a <= 'b0;

        #100;
        $finish;
    end

endmodule
