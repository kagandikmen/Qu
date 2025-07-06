// Reservation station of The Qu Processor
// Created:     2025-06-30
// Modified:    2025-07-07

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
        input   res_st_addr_t wr_addr,
        input   res_st_cell_t wr_in,

        input   res_st_addr_t rd1_addr,
        output  res_st_cell_t rd1_out,

        input   res_st_addr_t rd2_addr,
        output  res_st_cell_t rd2_out,

        input   res_st_addr_t rd3_addr,
        output  res_st_cell_t rd3_out,

        input   res_st_addr_t rd4_addr,
        output  res_st_cell_t rd4_out,

        input   logic retire_en,
        input   rob_addr_t retire_addr,
        input   phy_rf_data_t retire_value
    );

    res_st_cell_t [RES_ST_DEPTH-1:0] res_st;

    // write logic
    always_ff @(posedge clk)
    begin

        if(retire_en)
        begin
            for(int i=0; i<RES_ST_DEPTH; i++)
            begin
                if(res_st[i].busy == 1'b1)
                begin
                    if(res_st[i].qj == retire_addr)
                    begin
                        res_st[i].qj <= 'b0;
                        res_st[i].vj <= retire_value;
                    end

                    if(res_st[i].qk == retire_addr)
                    begin
                        res_st[i].qk <= 'b0;
                        res_st[i].vk <= retire_value;
                    end
                end
            end
        end

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
        rd3_out = res_st[rd3_addr];
        rd4_out = res_st[rd4_addr];
    end

endmodule

`endif
