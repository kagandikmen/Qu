// Execute stage of The Qu Processor
// Created:     2025-07-04
// Modified:    2025-07-12

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
        input   res_st_cell_t op_in,

        output  [31:0] value_out,
        output  res_st_cell_t op_out
    );

    logic [2:0] op_in_optype;
    logic op_in_alu_cu_input_sel;
    logic [1:0] op_in_alu_subunit_res_sel;
    logic [3:0] op_in_alu_subunit_op_sel;

    logic [31:0] alu_result_out;

    assign op_out = op_in;
    assign value_out = alu_result_out;

    assign op_in_optype = op_in.op.optype;
    assign op_in_alu_cu_input_sel = op_in.op.alu_cu_input_sel;
    assign op_in_alu_subunit_res_sel = op_in.op.alu_subunit_res_sel;
    assign op_in_alu_subunit_op_sel = op_in.op.alu_subunit_op_sel;

    alu #(
        .OPERAND_LENGTH(32)
    ) qu_alu (
        .opd1(op_in.vj),
        .opd2(op_in.vk),
        .opd3(),
        .opd4(),
        .cu_input_sel(op_in_alu_cu_input_sel),
        .subunit_res_sel(op_in_alu_subunit_res_sel),
        .subunit_op_sel(op_in_alu_subunit_op_sel),
        .alu_result(alu_result_out),
        .comp_result()
    );

endmodule

`endif
