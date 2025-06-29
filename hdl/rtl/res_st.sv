// Reservation station of The Qu Processor
// Created:     2025-06-30
// Modified:    

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_RES_ST
`define QU_RES_ST

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module res_st
    #(
        parameter int RES_ST_DEPTH = 32
    )(
        input   logic clk,
        input   logic rst,

        input   logic wr_en,
        input   logic [$clog2(RES_ST_DEPTH)-1:0] wr_addr,
        input   res_st_cell_t wr_in,

        input   logic [$clog2(RES_ST_DEPTH)-1:0] rd1_addr,
        output  res_st_cell_t rd1_out,

        input   logic [$clog2(RES_ST_DEPTH)-1:0] rd2_addr,
        output  res_st_cell_t rd2_out
    );

    res_st_cell_t [RES_ST_DEPTH-1:0] res_st;

    // write logic
    always_ff @(posedge clk)
    begin
        if(wr_en)
        begin
            res_st[wr_addr] <= wr_in;
        end

        // reset logic
        if(rst)
        begin
            for(int i=0; i<RES_ST_DEPTH; i++)
            begin
                res_st[i] <= 'b0;
            end
        end
    end
    
    // read logic
    always_comb
    begin
        rd1_out = res_st[rd1_addr];
        rd2_out = res_st[rd2_addr];
    end

endmodule

`endif
