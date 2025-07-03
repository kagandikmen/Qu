// Top back-end module of The Qu Processor
// Created:     2025-07-03
// Modified:    

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_BACK
`define QU_BACK

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module back_end
    #()(
        input   logic clk,
        input   logic rst,
        input   logic schedule_en,

        output  res_st_addr_t res_st_rd1_addr,
        input   res_st_cell_t res_st_rd1_in,
        output  res_st_addr_t res_st_rd2_addr,
        input   res_st_cell_t res_st_rd2_in,
        output  res_st_addr_t res_st_rd3_addr,
        input   res_st_cell_t res_st_rd3_in,
        output  res_st_addr_t res_st_rd4_addr,
        input   res_st_cell_t res_st_rd4_in
    );

    res_st_addr_t schedule_res_st_rd1_addr_out;
    res_st_cell_t schedule_res_st_rd1_in;

    res_st_addr_t schedule_res_st_rd2_addr_out;
    res_st_cell_t schedule_res_st_rd2_in;

    res_st_addr_t schedule_res_st_rd3_addr_out;
    res_st_cell_t schedule_res_st_rd3_in;

    res_st_addr_t schedule_res_st_rd4_addr_out;
    res_st_cell_t schedule_res_st_rd4_in;

    assign res_st_rd1_addr = schedule_res_st_rd1_addr_out;
    assign schedule_res_st_rd1_in = res_st_rd1_in;

    assign res_st_rd2_addr = schedule_res_st_rd2_addr_out;
    assign schedule_res_st_rd2_in = res_st_rd2_in;

    assign res_st_rd3_addr = schedule_res_st_rd3_addr_out;
    assign schedule_res_st_rd3_in = res_st_rd3_in;

    assign res_st_rd4_addr = schedule_res_st_rd4_addr_out;
    assign schedule_res_st_rd4_in = res_st_rd4_in;

    schedule qu_schedule (
        .clk(clk),
        .rst(rst),
        .en(schedule_en),
        .res_st_rd1_addr(schedule_res_st_rd1_addr_out),
        .res_st_rd1_in(schedule_res_st_rd1_in),
        .res_st_rd2_addr(schedule_res_st_rd2_addr_out),
        .res_st_rd2_in(schedule_res_st_rd2_in),
        .res_st_rd3_addr(schedule_res_st_rd3_addr_out),
        .res_st_rd3_in(schedule_res_st_rd3_in),
        .res_st_rd4_addr(schedule_res_st_rd4_addr_out),
        .res_st_rd4_in(schedule_res_st_rd4_in)
    );

endmodule

`endif
