// Schedule stage of The Qu Processor
// Created:     2025-07-03
// Modified:    2025-07-15

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_SCHEDULE
`define QU_SCHEDULE

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module schedule
    #()(
        input   logic clk,
        input   logic rst,
        input   logic en,

        output  res_st_addr_t res_st_rd1_addr,
        input   res_st_cell_t res_st_rd1_in,
        output  res_st_addr_t res_st_rd2_addr,
        input   res_st_cell_t res_st_rd2_in,
        output  res_st_addr_t res_st_rd3_addr,
        input   res_st_cell_t res_st_rd3_in,
        output  res_st_addr_t res_st_rd4_addr,
        input   res_st_cell_t res_st_rd4_in,

        output  logic fifo_wr1_en,
        output  logic fifo_wr2_en,
        
        output  res_st_cell_t op1_out,
        output  res_st_cell_t op2_out
    );

    res_st_addr_t rd_ptr;
    logic [3:0] issued_list;
    logic [3:0] issuing_list;
    logic fifo_wr1_en_buf;
    logic fifo_wr2_en_buf;

    assign fifo_wr1_en = fifo_wr1_en_buf && en;
    assign fifo_wr2_en = fifo_wr2_en_buf && en;

    always_comb
    begin
        fifo_wr1_en_buf = 0;
        op1_out = 'b0;

        issuing_list = 4'b0000;

        res_st_rd1_addr = rd_ptr;
        res_st_rd2_addr = rd_ptr + 1;
        res_st_rd3_addr = rd_ptr + 2;
        res_st_rd4_addr = rd_ptr + 3;

        // integer & control

        if(res_st_rd1_in.op.optype[0] && !res_st_rd1_in.op.optype[3] && !issued_list[0] && res_st_rd1_in.qj == 0 && res_st_rd1_in.qk == 0)
        begin
            fifo_wr1_en_buf = 1'b1;
            op1_out = res_st_rd1_in;
            issuing_list[0] = 1'b1;
        end
        else if(res_st_rd2_in.op.optype[0] && !res_st_rd2_in.op.optype[3] && !issued_list[1] && res_st_rd2_in.qj == 0 && res_st_rd2_in.qk == 0)
        begin
            fifo_wr1_en_buf = 1'b1;
            op1_out = res_st_rd2_in;
            issuing_list[1] = 1'b1;
        end
        else if(res_st_rd3_in.op.optype[0] && !res_st_rd3_in.op.optype[3] && !issued_list[2] && res_st_rd3_in.qj == 0 && res_st_rd3_in.qk == 0)
        begin
            fifo_wr1_en_buf = 1'b1;
            op1_out = res_st_rd3_in;
            issuing_list[2] = 1'b1;
        end
        else if(res_st_rd4_in.op.optype[0] && !res_st_rd4_in.op.optype[3] && !issued_list[3] && res_st_rd4_in.qj == 0 && res_st_rd4_in.qk == 0)
        begin
            fifo_wr1_en_buf = 1'b1;
            op1_out = res_st_rd4_in;
            issuing_list[3] = 1'b1;
        end

        // load & store

        if(res_st_rd1_in.op.optype[0] && res_st_rd1_in.op.optype[3] && !issued_list[0] && res_st_rd1_in.qj == 0 && res_st_rd1_in.qk == 0)
        begin
            fifo_wr2_en_buf = 1'b1;
            op2_out = res_st_rd1_in;
            issuing_list[0] = 1'b1;
        end
        else if(res_st_rd2_in.op.optype[0] && res_st_rd2_in.op.optype[3] && !issued_list[1] && res_st_rd2_in.qj == 0 && res_st_rd2_in.qk == 0)
        begin
            fifo_wr2_en_buf = 1'b1;
            op2_out = res_st_rd2_in;
            issuing_list[1] = 1'b1;
        end
        else if(res_st_rd3_in.op.optype[0] && res_st_rd3_in.op.optype[3] && !issued_list[2] && res_st_rd3_in.qj == 0 && res_st_rd3_in.qk == 0)
        begin
            fifo_wr2_en_buf = 1'b1;
            op2_out = res_st_rd3_in;
            issuing_list[2] = 1'b1;
        end
        else if(res_st_rd4_in.op.optype[0] && res_st_rd4_in.op.optype[3] && !issued_list[3] && res_st_rd4_in.qj == 0 && res_st_rd4_in.qk == 0)
        begin
            fifo_wr2_en_buf = 1'b1;
            op2_out = res_st_rd4_in;
            issuing_list[3] = 1'b1;
        end
    end

    always_ff @(posedge clk)
    begin

        if(rst)
        begin
            issued_list <= 'b0;
            rd_ptr <= 'b0;
        end
        else if(en)
        begin
            issued_list <= (issued_list | issuing_list);

            if((issued_list | issuing_list) == 4'b1111)
            begin
                issued_list <= 'b0;
                rd_ptr <= rd_ptr + 4;
            end
        end
    end

endmodule

`endif
