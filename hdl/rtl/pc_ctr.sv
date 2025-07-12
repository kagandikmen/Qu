// PC Counter
// Created:     2025-06-23
// Modified:    2025-07-13

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_PC_CTR
`define QU_PC_CTR

`include "../lib/qu_common.svh"

import qu_common::*;

module pc_ctr
    #(
        parameter PC_WIDTH = 32,
        parameter PC_INC = 1,
        parameter PC_RESET_VAL = 0
    )(
        input logic clk,
        input logic rst,
        input logic en,

        input logic pc_override,
        input logic [PC_WIDTH-1:0] pc_in,

        output pc_t current_pc,
        output pc_t next_pc
    );

    pc_t current_pc_reg;
    pc_t next_pc_reg;

    always_ff @(posedge clk)
    begin
        if(en) 
        begin
            current_pc_reg <= next_pc_reg;
            next_pc_reg <= next_pc_reg + PC_INC;
        end

        if(pc_override) next_pc_reg <= pc_in;
        
        if(rst) next_pc_reg <= PC_RESET_VAL;
    end

    assign next_pc = next_pc_reg;
    assign current_pc = current_pc_reg;

endmodule

`endif