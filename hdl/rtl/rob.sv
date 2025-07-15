// Reorder buffer of The Qu Processor
// Created:     2025-07-05
// Modified:    2025-07-15

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_ROB
`define QU_ROB

`include "../lib/qu_common.svh"

import qu_common::*;

module rob
    #()(
        input   logic clk,
        input   logic rst,

        input   logic wr1_en,
        input   rob_addr_t wr1_addr,
        input   rob_cell_t wr1_in,

        input   logic wr2_en,
        input   rob_addr_t wr2_addr,
        input   rob_cell_t wr2_in,

        input   logic wr3_en,
        input   rob_addr_t wr3_addr,
        input   rob_cell_t wr3_in,

        input   rob_addr_t rd1_addr,
        output  rob_cell_t rd1_out,

        input   rob_addr_t rd2_addr,
        output  rob_cell_t rd2_out
    );

    rob_cell_t [ROB_DEPTH-1:0] rob;

    logic wr12_collide;
    logic wr13_collide;
    logic wr23_collide;

    assign wr12_collide = wr1_en && wr2_en && (wr1_addr == wr2_addr);
    assign wr13_collide = wr1_en && wr3_en && (wr1_addr == wr3_addr);
    assign wr23_collide = wr2_en && wr3_en && (wr2_addr == wr3_addr);

    always_ff @(posedge clk)
    begin
        if(wr1_en && !wr12_collide && !wr13_collide)
        begin
            rob[wr1_addr] <= wr1_in;
        end

        if(wr2_en && !wr12_collide && !wr23_collide)
        begin
            rob[wr2_addr] <= wr2_in;
        end

        if(wr3_en && !wr13_collide && !wr23_collide)
        begin
            rob[wr3_addr] <= wr3_in;
        end

        if(rst)
        begin
            for(int i=0; i<ROB_DEPTH; i++)
            begin
                rob[i] <= 'b0;
            end
        end
    end

    always_comb
    begin
        rd1_out = rob[rd1_addr];
        rd2_out = rob[rd2_addr];
    end

endmodule

`endif
