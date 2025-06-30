// Rename stage of The Qu Processor
// Created:     2025-06-30
// Modified:    

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_RENAME
`define QU_RENAME

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module rename
    #()(
        input   logic clk,
        input   logic rst,
        input   logic en,

        input   uop_t uop_in,

        // busy table interface
        output  logic [PHY_RF_ADDR_WIDTH-1:0] busy_table_rd1_addr,
        input   logic busy_table_data1_in,
        output  logic [PHY_RF_ADDR_WIDTH-1:0] busy_table_rd2_addr,
        input   logic busy_table_data2_in,

        // physical register file interface
        output  logic [PHY_RF_ADDR_WIDTH-1:0] phy_rf_rs1_addr_out,
        input   logic [31:0] phy_rf_rs1_data_in,
        output  logic [PHY_RF_ADDR_WIDTH-1:0] phy_rf_rs2_addr_out,
        input   logic [31:0] phy_rf_rs2_data_in,

        // reservation station interface
        output  logic res_st_wr_en_out,
        output  res_st_addr_t res_st_wr_addr_out,
        output  res_st_cell_t res_st_data_out
    );

    res_st_addr_t wr_ptr;
    res_st_cell_t data_out_buf;

    assign res_st_wr_en_out = en;
    assign res_st_wr_addr_out = wr_ptr;
    assign res_st_data_out = data_out_buf;

    always_comb
    begin
        // check if the source registers are currently being written
        busy_table_rd1_addr = uop_in.uop_ic.rs1;
        busy_table_rd2_addr = uop_in.uop_ic.rs2;
        
        // read the registers
        phy_rf_rs1_addr_out = uop_in.uop_ic.rs1;
        phy_rf_rs2_addr_out = uop_in.uop_ic.rs2;

        if(busy_table_data1_in)
        begin
            data_out_buf.qj = uop_in.uop_ic.rs1;
            data_out_buf.vj = 'd0;
        end
        else
        begin
            data_out_buf.qj = 'd0;
            data_out_buf.vj = phy_rf_rs1_data_in;
        end

        if(busy_table_data2_in)
        begin
            data_out_buf.qk = uop_in.uop_ic.rs2;
            data_out_buf.vk = 'd0;
        end
        else
        begin
            data_out_buf.qk = 'd0;
            data_out_buf.vk = phy_rf_rs2_data_in;
        end

        data_out_buf.a = 'd0;
        data_out_buf.op = uop_in[RES_ST_OP_WIDTH-1:0];
        data_out_buf.busy = 1'b1;
    end

    always_ff @(posedge clk)
    begin
        if(rst)
        begin
            wr_ptr <= 'b0;
        end
        else if(en)
        begin
            wr_ptr <= wr_ptr + 1;
        end
    end

endmodule

`endif
