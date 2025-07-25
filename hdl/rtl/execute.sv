// Execute stage of The Qu Processor
// Created:     2025-07-04
// Modified:    2025-07-15

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_EXECUTE
`define QU_EXECUTE

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module execute
    #()(
        input   res_st_cell_t op1_in,
        input   res_st_cell_t op2_in,

        output  logic [31:0] value1_out,
        output  logic [31:0] value2_out,

        output  logic comp_result,

        output  res_st_cell_t op1_out,
        output  res_st_cell_t op2_out
    );

    logic [3:0] op1_in_optype;
    logic op1_in_alu_cu_input_sel;
    logic [1:0] op1_in_alu_subunit_res_sel;
    logic [3:0] op1_in_alu_subunit_op_sel;

    logic [31:0] alu_opd1;
    logic [31:0] alu_opd2;
    logic [31:0] alu_opd3;
    logic [31:0] alu_opd4;
    logic [31:0] alu_result_out;
    logic [31:0] alu_comp_result_out;

    logic [31:0] ldst_unit_opd1;
    logic [31:0] ldst_unit_opd2;
    logic [31:0] ldst_unit_addr_out;

    assign op1_out = op1_in;
    assign value1_out = alu_result_out;
    assign comp_result = alu_comp_result_out[0];

    assign op2_out = op2_in;
    assign value2_out = ldst_unit_addr_out;

    assign op1_in_optype = op1_in.op.optype;
    assign op1_in_alu_cu_input_sel = op1_in.op.alu_cu_input_sel;
    assign op1_in_alu_subunit_res_sel = op1_in.op.alu_subunit_res_sel;
    assign op1_in_alu_subunit_op_sel = op1_in.op.alu_subunit_op_sel;

    always_comb
    begin

        ldst_unit_opd1 = op2_in.vj;
        ldst_unit_opd2 = op2_in.a;

        case(op1_in.op.alu_input_sel)
            ALU_INPUT_SEL_R_I:
            begin
                alu_opd1 = (op1_in.op.rs1_valid) ? op1_in.vj
                         : 'd0;
        
                alu_opd2 = (op1_in.op.rs2_valid) ? op1_in.vk
                         : (op1_in.op.imm_valid) ? op1_in.a
                         : 'd0;
                
                alu_opd3 = 'd0;
                alu_opd4 = 'd0;
            end
            ALU_INPUT_SEL_B:
            begin
                alu_opd1 = op1_in.pc;
                alu_opd2 = op1_in.a;
                alu_opd3 = op1_in.vj;
                alu_opd4 = op1_in.vk;
            end
            ALU_INPUT_SEL_JAL:
            begin
                alu_opd1 = op1_in.pc;
                alu_opd2 = op1_in.a;
                alu_opd3 = 'd0;
                alu_opd4 = 'd0;
            end
            ALU_INPUT_SEL_JALR:
            begin
                alu_opd1 = op1_in.vj;
                alu_opd2 = op1_in.a;
                alu_opd3 = 'd0;
                alu_opd4 = 'd0;
            end
            ALU_INPUT_SEL_LUI:
            begin
                alu_opd1 = op1_in.a;
                alu_opd2 = 'd0;
                alu_opd3 = 'd0;
                alu_opd4 = 'd0;
            end
            ALU_INPUT_SEL_AUIPC:
            begin
                alu_opd1 = op1_in.pc;
                alu_opd2 = op1_in.a;
                alu_opd3 = 'd0;
                alu_opd4 = 'd0;
            end
            default:
            begin
                alu_opd1 = 'd0;
                alu_opd2 = 'd0;
                alu_opd3 = 'd0;
                alu_opd4 = 'd0;
            end
        endcase
    end
    
    alu #(
        .OPERAND_LENGTH(32)
    ) qu_alu (
        .opd1(alu_opd1),
        .opd2(alu_opd2),
        .opd3(alu_opd3),
        .opd4(alu_opd4),
        .cu_input_sel(op1_in_alu_cu_input_sel),
        .subunit_res_sel(op1_in_alu_subunit_res_sel),
        .subunit_op_sel(op1_in_alu_subunit_op_sel),
        .alu_result(alu_result_out),
        .comp_result(alu_comp_result_out)
    );

    ldst_unit qu_ldst_unit (
        .opd1(ldst_unit_opd1),
        .opd2(ldst_unit_opd2),
        .addr_out(ldst_unit_addr_out)
    );

endmodule

`endif
