// Micro-op library for The Qu Processor
// Created:     2025-06-28
// Modified:    2025-07-03

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_UOP
`define QU_UOP

package qu_uop;

    //
    // configuration parameters
    //

    parameter int UOP_WIDTH = 67;
    parameter int PHY_RF_DEPTH = 128;
    parameter int PHY_RF_ADDR_WIDTH = $clog2(PHY_RF_DEPTH);

    //
    //  micro-op encoding parameters
    //

    parameter logic [2:0] OPTYPE_INT        = 3'b001;
    parameter logic [2:0] OPTYPE_CONT       = 3'b011;
    parameter logic [2:0] OPTYPE_LOAD       = 3'b101;
    parameter logic [2:0] OPTYPE_STORE      = 3'b111;

    parameter logic RD_VALID    = 1'b1;
    parameter logic RD_INVALID  = 1'b0;

    parameter logic RS1_VALID   = 1'b1;
    parameter logic RS1_INVALID = 1'b0;

    parameter logic RS2_VALID   = 1'b1;
    parameter logic RS2_INVALID = 1'b0;

    parameter logic IMM_VALID   = 1'b1;
    parameter logic IMM_INVALID = 1'b0;

    //  luftALU parameters

    parameter logic ALU_CU_INPUT_OPD3_OPD4_SEL_YES      = 1'b1;
    parameter logic ALU_CU_INPUT_OPD3_OPD4_SEL_NO       = 1'b0;

    parameter logic [1:0] ALU_SUBUNIT_RES_SEL_ADDER     = 2'b00;
    parameter logic [1:0] ALU_SUBUNIT_RES_SEL_LOGIC     = 2'b01;
    parameter logic [1:0] ALU_SUBUNIT_RES_SEL_SHIFT     = 2'b10;
    parameter logic [1:0] ALU_SUBUNIT_RES_SEL_COMP      = 2'b11;

    parameter logic [3:0] ALU_SUBUNIT_OP_SEL_ADDITION       = 4'b0000;
    parameter logic [3:0] ALU_SUBUNIT_OP_SEL_SUBTRACTION    = 4'b1000;
    parameter logic [3:0] ALU_SUBUNIT_OP_SEL_AND            = 4'b0111;
    parameter logic [3:0] ALU_SUBUNIT_OP_SEL_OR             = 4'b0110;
    parameter logic [3:0] ALU_SUBUNIT_OP_SEL_XOR            = 4'b0100;
    parameter logic [3:0] ALU_SUBUNIT_OP_SEL_NOT_OPD1       = 4'b0000;
    parameter logic [3:0] ALU_SUBUNIT_OP_SEL_NOT_OPD2       = 4'b0001;
    parameter logic [3:0] ALU_SUBUNIT_OP_SEL_SRL_SRLI       = 4'b0001;
    parameter logic [3:0] ALU_SUBUNIT_OP_SEL_SLL_SLLI       = 4'b0011;
    parameter logic [3:0] ALU_SUBUNIT_OP_SEL_SRA_SRAI       = 4'b0111;
    parameter logic [3:0] ALU_SUBUNIT_OP_SEL_IS_EQ          = 4'b0000;
    parameter logic [3:0] ALU_SUBUNIT_OP_SEL_IS_NE          = 4'b0001;
    parameter logic [3:0] ALU_SUBUNIT_OP_SEL_IS_GE          = 4'b0010;
    parameter logic [3:0] ALU_SUBUNIT_OP_SEL_IS_GEU         = 4'b0110;
    parameter logic [3:0] ALU_SUBUNIT_OP_SEL_IS_LT          = 4'b0011;
    parameter logic [3:0] ALU_SUBUNIT_OP_SEL_IS_LTU         = 4'b0111;

    //
    //  type definitions
    //

    // uop_ic_t: integer & control
    typedef struct packed {
        logic [31:0] imm;
        logic [PHY_RF_ADDR_WIDTH-1:0] rs2;
        logic [PHY_RF_ADDR_WIDTH-1:0] rs1;
        logic [PHY_RF_ADDR_WIDTH-1:0] rd;
        logic imm_valid;
        logic rs2_valid;
        logic rs1_valid;
        logic rd_valid;
        logic [3:0] alu_subunit_op_sel;
        logic [1:0] alu_subunit_res_sel;
        logic alu_cu_input_opd3_opd4_sel;
        logic [2:0] optype;
    } uop_ic_t;
    
    // uop_ldst_t: load & store
    typedef struct packed {
        logic [31:0] imm;
        logic [PHY_RF_ADDR_WIDTH-1:0] rs2;
        logic [PHY_RF_ADDR_WIDTH-1:0] rs1;
        logic [PHY_RF_ADDR_WIDTH-1:0] rd;
        logic imm_valid;
        logic rs2_valid;
        logic rs1_valid;
        logic rd_valid;
        logic [3:0] ignore;
        logic [2:0] funct3;
        logic [2:0] optype;
    } uop_ldst_t; 

    typedef union packed {
        uop_ic_t uop_ic;
        uop_ldst_t uop_ldst;
    } uop_t;

endpackage

`endif
