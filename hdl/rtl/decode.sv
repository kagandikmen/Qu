// Decode stage of the instruction pipeline
// Created:     2025-06-27
// Modified:    2025-07-15

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_DECODE
`define QU_DECODE

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module decode
    #(
        parameter INSTR_WIDTH = 32,
        parameter UOP_WIDTH = 60
    )(
        input logic [INSTR_WIDTH-1:0] instr_in,
        input pc_t pc_in,

        output logic nop,
        output logic invalid,
        output uop_t uop_out
    );

    logic [6:0] opcode;
    logic [4:0] rd, rs1, rs2;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [11:0] imm12;
    logic [12:0] imm13;
    logic [20:0] imm21;
    logic [31:0] imm32;

    logic valid;
    uop_t uop_out_buf;

    assign opcode   = instr_in[6:0];
    assign rd       = instr_in[11:7];
    assign funct3   = instr_in[14:12];
    assign rs1      = instr_in[19:15];
    assign rs2      = instr_in[24:20];
    assign funct7   = instr_in[31:25];

    assign imm12   = instr_in[31:20];
    assign imm13   = {instr_in[31], instr_in[7], instr_in[30:25], instr_in[11:8], 1'b0};
    assign imm21   = {instr_in[31], instr_in[19:12], instr_in[20], instr_in[30:21], 1'b0};
    assign imm32   = {instr_in[31:12], 12'b0};

    assign nop      = ((opcode == R_OPCODE) || (opcode == LOAD_OPCODE) || (opcode == I_OPCODE) || (opcode == LUI_OPCODE) || (opcode == AUIPC_OPCODE))
                    && (rd == 5'b00000);

    assign valid    = ((opcode == R_OPCODE)         || (opcode == I_OPCODE)     || (opcode == LOAD_OPCODE)
                    || (opcode == S_OPCODE)         || (opcode == B_OPCODE)     || (opcode == JAL_OPCODE)
                    || (opcode == JALR_OPCODE)      || (opcode == LUI_OPCODE)   || (opcode == AUIPC_OPCODE)
                    || (opcode == SYSCALL_OPCODE)   || (opcode == CSR_OPCODE));

    assign invalid  = ~valid;

    assign uop_out = uop_out_buf;

    always_comb
    begin
        uop_out_buf = 'b0;
        uop_out_buf.uop_ic.pc = pc_in;
        uop_out_buf.uop_ic.phyreg_old = 'd0;

        if(opcode == R_OPCODE)
        begin
            uop_out_buf.uop_ic.imm = 'd0;
            uop_out_buf.uop_ic.imm_valid = IMM_INVALID;
            uop_out_buf.uop_ic.rs2 = rs2;
            uop_out_buf.uop_ic.rs2_valid = RS2_VALID;
            uop_out_buf.uop_ic.rs1 = rs1;
            uop_out_buf.uop_ic.rs1_valid = RS1_VALID;
            uop_out_buf.uop_ic.rd = rd;
            uop_out_buf.uop_ic.rd_valid = RD_VALID;
            case(funct3)
                FUNCT3_ADD  : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_ADDITION;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_ADDER;
                end
                FUNCT3_SUB  : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_SUBTRACTION;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_ADDER;
                end
                FUNCT3_SLL  : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_SLL_SLLI;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_SHIFT;
                end
                FUNCT3_SLT  : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_IS_LT;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_COMP;
                end
                FUNCT3_SLTU : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_IS_LTU;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_COMP;
                end
                FUNCT3_XOR  : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_XOR;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_LOGIC;
                end
                FUNCT3_SRL  : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_SRL_SRLI;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_SHIFT;
                end
                FUNCT3_SRA  : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_SRA_SRAI;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_SHIFT;
                end
                FUNCT3_OR   : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_OR;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_LOGIC;
                end
                FUNCT3_AND  : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_AND;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_LOGIC;
                end
            endcase
            uop_out_buf.uop_ic.alu_cu_input_sel = ALU_CU_INPUT_SEL_OPD1_OPD2;
            uop_out_buf.uop_ic.alu_input_sel = ALU_INPUT_SEL_R_I;
            uop_out_buf.uop_ic.optype = OPTYPE_INT;
        end
        else if(opcode == I_OPCODE)
        begin
            uop_out_buf.uop_ic.imm = imm12;
            uop_out_buf.uop_ic.imm_valid = IMM_VALID;
            uop_out_buf.uop_ic.rs2 = 'd0;
            uop_out_buf.uop_ic.rs2_valid = RS2_INVALID;
            uop_out_buf.uop_ic.rs1 = rs1;
            uop_out_buf.uop_ic.rs1_valid = RS1_VALID;
            uop_out_buf.uop_ic.rd = rd;
            uop_out_buf.uop_ic.rd_valid = RD_VALID;
            case(funct3)
                FUNCT3_ADDI  : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_ADDITION;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_ADDER;
                end
                FUNCT3_SLLI  : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_SLL_SLLI;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_SHIFT;
                end
                FUNCT3_SLTI  : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_IS_LT;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_COMP;
                end
                FUNCT3_SLTIU : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_IS_LTU;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_COMP;
                end
                FUNCT3_XORI  : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_XOR;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_LOGIC;
                end
                FUNCT3_SRLI  : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_SRL_SRLI;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_SHIFT;
                end
                FUNCT3_SRAI  : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_SRA_SRAI;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_SHIFT;
                end
                FUNCT3_ORI   : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_OR;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_LOGIC;
                end
                FUNCT3_ANDI  : 
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_AND;
                    uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_LOGIC;
                end
            endcase
            uop_out_buf.uop_ic.alu_cu_input_sel = ALU_CU_INPUT_SEL_OPD1_OPD2;
            uop_out_buf.uop_ic.alu_input_sel = ALU_INPUT_SEL_R_I;
            uop_out_buf.uop_ic.optype = OPTYPE_INT;
        end
        else if(opcode == B_OPCODE)
        begin
            uop_out_buf.uop_ic.imm = imm13;
            uop_out_buf.uop_ic.imm_valid = IMM_VALID;
            uop_out_buf.uop_ic.rs2 = rs2;
            uop_out_buf.uop_ic.rs2_valid = RS2_VALID;
            uop_out_buf.uop_ic.rs1 = rs1;
            uop_out_buf.uop_ic.rs1_valid = RS1_VALID;
            uop_out_buf.uop_ic.rd = 'd0;
            uop_out_buf.uop_ic.rd_valid = RD_INVALID;
            case(funct3)
                FUNCT3_BEQ:
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_IS_EQ;
                end
                FUNCT3_BNE:
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_IS_NE;
                end
                FUNCT3_BLT:
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_IS_LT;
                end
                FUNCT3_BGE:
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_IS_GE;
                end
                FUNCT3_BLTU:
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_IS_LTU;
                end
                FUNCT3_BGEU:
                begin
                    uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_IS_GEU;
                end
            endcase
            uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_ADDER;
            uop_out_buf.uop_ic.alu_cu_input_sel = ALU_CU_INPUT_SEL_OPD3_OPD4;
            uop_out_buf.uop_ic.alu_input_sel = ALU_INPUT_SEL_B;
            uop_out_buf.uop_ic.optype = OPTYPE_BRANCH;
        end
        else if(opcode == LOAD_OPCODE)
        begin
            uop_out_buf.uop_ldst.imm = imm12;
            uop_out_buf.uop_ldst.imm_valid = IMM_VALID;
            uop_out_buf.uop_ldst.rs2 = 'd0;
            uop_out_buf.uop_ldst.rs2_valid = RS2_INVALID;
            uop_out_buf.uop_ldst.rs1 = rs1;
            uop_out_buf.uop_ldst.rs1_valid = RS1_VALID;
            uop_out_buf.uop_ldst.rd = rd;
            uop_out_buf.uop_ldst.rd_valid = RD_VALID;
            uop_out_buf.uop_ldst.ignore = 'd0;
            uop_out_buf.uop_ldst.funct3 = funct3;
            uop_out_buf.uop_ldst.optype = OPTYPE_LOAD;
        end
        else if(opcode == S_OPCODE)
        begin
            uop_out_buf.uop_ldst.imm = imm13;
            uop_out_buf.uop_ldst.imm_valid = IMM_VALID;
            uop_out_buf.uop_ldst.rs2 = rs2;
            uop_out_buf.uop_ldst.rs2_valid = RS2_VALID;
            uop_out_buf.uop_ldst.rs1 = rs1;
            uop_out_buf.uop_ldst.rs1_valid = RS1_VALID;
            uop_out_buf.uop_ldst.rd = 'd0;
            uop_out_buf.uop_ldst.rd_valid = RD_INVALID;
            uop_out_buf.uop_ldst.ignore = 'd0;
            uop_out_buf.uop_ldst.funct3 = funct3;
            uop_out_buf.uop_ldst.optype = OPTYPE_STORE;
        end
        else if(opcode == JAL_OPCODE)
        begin
            uop_out_buf.uop_ic.imm = imm21;
            uop_out_buf.uop_ic.imm_valid = IMM_VALID;
            uop_out_buf.uop_ic.rs2 = 'd0;
            uop_out_buf.uop_ic.rs2_valid = RS2_INVALID;
            uop_out_buf.uop_ic.rs1 = 'd0;
            uop_out_buf.uop_ic.rs1_valid = RS1_INVALID;
            uop_out_buf.uop_ic.rd = rd;
            uop_out_buf.uop_ic.rd_valid = RD_VALID;
            uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_ADDITION;
            uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_ADDER;
            uop_out_buf.uop_ic.alu_cu_input_sel = ALU_CU_INPUT_SEL_OPD1_OPD2;
            uop_out_buf.uop_ic.alu_input_sel = ALU_INPUT_SEL_JAL;
            uop_out_buf.uop_ic.optype = OPTYPE_CONT;
        end
        else if(opcode == JALR_OPCODE)
        begin
            uop_out_buf.uop_ic.imm = imm21;
            uop_out_buf.uop_ic.imm_valid = IMM_VALID;
            uop_out_buf.uop_ic.rs2 = 'd0;
            uop_out_buf.uop_ic.rs2_valid = RS2_INVALID;
            uop_out_buf.uop_ic.rs1 = rs1;
            uop_out_buf.uop_ic.rs1_valid = RS1_VALID;
            uop_out_buf.uop_ic.rd = rd;
            uop_out_buf.uop_ic.rd_valid = RD_VALID;
            uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_ADDITION;
            uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_ADDER;
            uop_out_buf.uop_ic.alu_cu_input_sel = ALU_CU_INPUT_SEL_OPD1_OPD2;
            uop_out_buf.uop_ic.alu_input_sel = ALU_INPUT_SEL_JALR;
            uop_out_buf.uop_ic.optype = OPTYPE_CONT;
        end
        else if(opcode == LUI_OPCODE)
        begin
            uop_out_buf.uop_ic.imm = imm32;
            uop_out_buf.uop_ic.imm_valid = IMM_VALID;
            uop_out_buf.uop_ic.rs2 = 'd0;
            uop_out_buf.uop_ic.rs2_valid = RS2_INVALID;
            uop_out_buf.uop_ic.rs1 = 'd0;
            uop_out_buf.uop_ic.rs1_valid = RS1_INVALID;
            uop_out_buf.uop_ic.rd = rd;
            uop_out_buf.uop_ic.rd_valid = RD_VALID;
            uop_out_buf.uop_ic.alu_subunit_op_sel = ALU_SUBUNIT_OP_SEL_ADDITION;
            uop_out_buf.uop_ic.alu_subunit_res_sel = ALU_SUBUNIT_RES_SEL_ADDER;
            uop_out_buf.uop_ic.alu_cu_input_sel = ALU_CU_INPUT_SEL_OPD1_OPD2;
            uop_out_buf.uop_ic.alu_input_sel = ALU_INPUT_SEL_LUI;
            uop_out_buf.uop_ic.optype = OPTYPE_INT;
        end
    end

endmodule

`endif
