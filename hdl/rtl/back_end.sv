// Top back-end module of The Qu Processor
// Created:     2025-07-03
// Modified:    2025-07-04

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
        input   res_st_cell_t res_st_rd4_in,

        output  logic [31:0] value_out,
        output  res_st_cell_t op_out
    );

    res_st_addr_t schedule_res_st_rd1_addr_out;
    res_st_cell_t schedule_res_st_rd1_in;
    res_st_addr_t schedule_res_st_rd2_addr_out;
    res_st_cell_t schedule_res_st_rd2_in;
    res_st_addr_t schedule_res_st_rd3_addr_out;
    res_st_cell_t schedule_res_st_rd3_in;
    res_st_addr_t schedule_res_st_rd4_addr_out;
    res_st_cell_t schedule_res_st_rd4_in;
    logic schedule_fifo_wr_en_out;
    res_st_cell_t schedule_op_out;

    logic fifo_sh_ex_rd_en;
    res_st_cell_t fifo_sh_ex_data_out;
    logic fifo_sh_ex_wr_en;
    res_st_cell_t fifo_sh_ex_data_in;
    logic fifo_sh_ex_empty_out;
    logic fifo_sh_ex_full_out;

    res_st_cell_t execute_op_in;
    logic [31:0] execute_value_out;
    res_st_cell_t execute_op_out;

    assign schedule_res_st_rd1_in = res_st_rd1_in;
    assign schedule_res_st_rd2_in = res_st_rd2_in;
    assign schedule_res_st_rd3_in = res_st_rd3_in;
    assign schedule_res_st_rd4_in = res_st_rd4_in;

    assign fifo_sh_ex_rd_en = !fifo_sh_ex_empty_out;
    assign fifo_sh_ex_wr_en = schedule_fifo_wr_en_out;
    assign fifo_sh_ex_data_in = schedule_op_out;

    assign execute_op_in = fifo_sh_ex_data_out;

    assign res_st_rd1_addr = schedule_res_st_rd1_addr_out;
    assign res_st_rd2_addr = schedule_res_st_rd2_addr_out;
    assign res_st_rd3_addr = schedule_res_st_rd3_addr_out;
    assign res_st_rd4_addr = schedule_res_st_rd4_addr_out;
    assign value_out = execute_value_out;
    assign op_out = execute_op_out;

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
        .res_st_rd4_in(schedule_res_st_rd4_in),
        .fifo_wr_en(schedule_fifo_wr_en_out),
        .op_out(schedule_op_out)
    );

    fifo #(
        .FIFO_WIDTH($bits(res_st_cell_t)),
        .FIFO_DEPTH(4)
    ) qu_fifo_sh_ex (
        .clk(clk),
        .rst(rst),
        .rd_en(fifo_sh_ex_rd_en),
        .data_out(fifo_sh_ex_data_out),
        .wr_en(fifo_sh_ex_wr_en),
        .data_in(fifo_sh_ex_data_in),
        .empty(fifo_sh_ex_empty_out),
        .almost_empty(),
        .full(fifo_sh_ex_full_out),
        .almost_full()
    );

    execute qu_execute (
        .op_in(execute_op_in),
        .value_out(execute_value_out),
        .op_out(execute_op_out)
    );

endmodule

`endif
