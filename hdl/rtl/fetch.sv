// Fetch stage of the instruction pipeline
// Created:     2025-06-24
// Modified:    2025-07-14

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_FETCH
`define QU_FETCH

`include "../lib/qu_common.svh"

import qu_common::*;

module fetch
    #(
        parameter INSTR_WIDTH = 32,
        parameter PC_WIDTH = 12,
        parameter PC_RESET_VAL = 0
    )(
        input   logic clk,
        input   logic rst,

        input   logic branch,
        input   logic jump,
        input   logic exception,
        input   logic stall,

        input   pc_t pc_override_in,

        input   logic [INSTR_WIDTH-1:0] instr_in,
        output  logic [INSTR_WIDTH-1:0] instr_out,

        output  pc_t pc,
        output  pc_t next_pc
    );

    logic pc_override;
    pc_t pc_current_pc_out;
    pc_t pc_next_pc_out;

    assign pc_override = branch | jump | exception;
    assign pc = pc_current_pc_out;
    assign next_pc = pc_next_pc_out;

    assign instr_out = instr_in;

    //
    //  pc counter
    //

    pc_ctr #(
        .PC_WIDTH(PC_WIDTH),
        .PC_INC(4),
        .PC_RESET_VAL(PC_RESET_VAL)
    ) qu_pc_ctr (
        .clk(clk),
        .rst(rst),
        .en(!stall),
        .pc_override(pc_override),
        .pc_in(pc_override_in),
        .current_pc(pc_current_pc_out),
        .next_pc(pc_next_pc_out)
    );

    // TODO: Branch prediction

endmodule

`endif
