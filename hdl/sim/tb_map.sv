// Map stage testbench
// Created:     2025-06-29
// Modified:    2025-07-04

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`timescale 1ns/1ps

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module tb_map
    #()();

    localparam LOG_RF_DEPTH = 8;
    localparam PHY_RF_DEPTH = 16;

    logic clk;
    logic rst;
    logic en;

    uop_t uop_in;
    uop_t uop_out;

    logic full;

    logic busy_table_wr_en;
    logic [$clog2(PHY_RF_DEPTH)-1:0] busy_table_wr_addr;
    logic busy_table_data_out;

    map #(
        .LOG_RF_DEPTH(LOG_RF_DEPTH),
        .PHY_RF_DEPTH(PHY_RF_DEPTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .uop_in(uop_in),
        .uop_out(uop_out),
        .full(full),
        .busy_table_wr_en(busy_table_wr_en),
        .busy_table_wr_addr(busy_table_wr_addr),
        .busy_table_data_out(busy_table_data_out)
    );

    always #5   clk = ~clk;

    initial
    begin
        clk <= 1'b0;
        rst <= 1'b0;
        en <= 1'b1;
        uop_in.uop_ic <= '{default: 'b0};

        @(posedge clk);
        rst <= 1'b1;

        repeat(5) @(posedge clk);
        rst <= 1'b0;
        uop_in.uop_ic.imm = 'd0;
        uop_in.uop_ic.imm_valid = IMM_INVALID;
        uop_in.uop_ic.rs2 = 'd3;
        uop_in.uop_ic.rs2_valid = RS2_VALID;
        uop_in.uop_ic.rs1 = 'd2;
        uop_in.uop_ic.rs1_valid = RS1_VALID;
        uop_in.uop_ic.rd = 'd1;
        uop_in.uop_ic.rd_valid = RD_VALID;
        uop_in.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_ADDITION;
        uop_in.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_ADDER;
        uop_in.uop_ic.alu_cu_input_sel = ALU_CU_INPUT_SEL_OPD1_OPD2;
        uop_in.uop_ic.optype = OPTYPE_INT;
        
        @(posedge clk);
        uop_in.uop_ic.imm = 'd0;
        uop_in.uop_ic.imm_valid = IMM_INVALID;
        uop_in.uop_ic.rs2 = 'd3;
        uop_in.uop_ic.rs2_valid = RS2_VALID;
        uop_in.uop_ic.rs1 = 'd2;
        uop_in.uop_ic.rs1_valid = RS1_VALID;
        uop_in.uop_ic.rd = 'd1;
        uop_in.uop_ic.rd_valid = RD_VALID;
        uop_in.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_ADDITION;
        uop_in.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_ADDER;
        uop_in.uop_ic.alu_cu_input_sel = ALU_CU_INPUT_SEL_OPD1_OPD2;
        uop_in.uop_ic.optype = OPTYPE_INT;

        @(posedge clk);
        uop_in.uop_ic.imm = 'd0;
        uop_in.uop_ic.imm_valid = IMM_INVALID;
        uop_in.uop_ic.rs2 = 'd0;
        uop_in.uop_ic.rs2_valid = RS2_VALID;
        uop_in.uop_ic.rs1 = 'd2;
        uop_in.uop_ic.rs1_valid = RS1_VALID;
        uop_in.uop_ic.rd = 'd1;
        uop_in.uop_ic.rd_valid = RD_VALID;
        uop_in.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_SUBTRACTION;
        uop_in.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_ADDER;
        uop_in.uop_ic.alu_cu_input_sel = ALU_CU_INPUT_SEL_OPD1_OPD2;
        uop_in.uop_ic.optype = OPTYPE_INT;

        @(posedge clk);
        uop_in.uop_ic.imm = 'd0;
        uop_in.uop_ic.imm_valid = IMM_INVALID;
        uop_in.uop_ic.rs2 = 'd1;
        uop_in.uop_ic.rs2_valid = RS2_VALID;
        uop_in.uop_ic.rs1 = 'd1;
        uop_in.uop_ic.rs1_valid = RS1_VALID;
        uop_in.uop_ic.rd = 'd0;
        uop_in.uop_ic.rd_valid = RD_VALID;
        uop_in.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_SUBTRACTION;
        uop_in.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_ADDER;
        uop_in.uop_ic.alu_cu_input_sel = ALU_CU_INPUT_SEL_OPD1_OPD2;
        uop_in.uop_ic.optype = OPTYPE_INT;

        @(posedge clk);
        uop_in.uop_ic.imm = 'd0;
        uop_in.uop_ic.imm_valid = IMM_INVALID;
        uop_in.uop_ic.rs2 = 'd3;
        uop_in.uop_ic.rs2_valid = RS2_VALID;
        uop_in.uop_ic.rs1 = 'd1;
        uop_in.uop_ic.rs1_valid = RS1_VALID;
        uop_in.uop_ic.rd = 'd0;
        uop_in.uop_ic.rd_valid = RD_VALID;
        uop_in.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_SUBTRACTION;
        uop_in.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_ADDER;
        uop_in.uop_ic.alu_cu_input_sel = ALU_CU_INPUT_SEL_OPD1_OPD2;
        uop_in.uop_ic.optype = OPTYPE_INT;

        @(posedge clk);
        uop_in.uop_ic.imm = 'd0;
        uop_in.uop_ic.imm_valid = IMM_INVALID;
        uop_in.uop_ic.rs2 = 'd7;
        uop_in.uop_ic.rs2_valid = RS2_VALID;
        uop_in.uop_ic.rs1 = 'd7;
        uop_in.uop_ic.rs1_valid = RS1_VALID;
        uop_in.uop_ic.rd = 'd6;
        uop_in.uop_ic.rd_valid = RD_VALID;
        uop_in.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_SUBTRACTION;
        uop_in.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_ADDER;
        uop_in.uop_ic.alu_cu_input_sel = ALU_CU_INPUT_SEL_OPD1_OPD2;
        uop_in.uop_ic.optype = OPTYPE_INT;

        @(posedge clk);
        uop_in.uop_ic.imm = 'd0;
        uop_in.uop_ic.imm_valid = IMM_INVALID;
        uop_in.uop_ic.rs2 = 'd5;
        uop_in.uop_ic.rs2_valid = RS2_VALID;
        uop_in.uop_ic.rs1 = 'd5;
        uop_in.uop_ic.rs1_valid = RS1_VALID;
        uop_in.uop_ic.rd = 'd5;
        uop_in.uop_ic.rd_valid = RD_VALID;
        uop_in.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_SUBTRACTION;
        uop_in.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_ADDER;
        uop_in.uop_ic.alu_cu_input_sel = ALU_CU_INPUT_SEL_OPD1_OPD2;
        uop_in.uop_ic.optype = OPTYPE_INT;

        repeat(6) @(posedge clk);
        en <= 1'b0;
        uop_in.uop_ic <= '{default: 'b0};

        #100;
        $finish;
    end

endmodule
