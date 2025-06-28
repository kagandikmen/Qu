// Decode stage of the instruction pipeline
// Created:     2025-06-27
// Modified:    2025-06-28

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_DECODE
`define QU_DECODE

`include "../lib/qu_common.svh"

import qu_common::*;

module decode
    #(
        parameter INSTR_WIDTH = 32
    )(
        input logic [INSTR_WIDTH-1:0] instr_in,

        output logic nop,
        output logic invalid,
        output logic [INSTR_WIDTH-1:0] instr_out
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

    assign nop      = ((opcode == R_OPCODE) || (opcode == I_OPCODE) || (opcode == LUI_OPCODE) || (opcode == AUIPC_OPCODE))
                    && (rd == 5'b00000);

    assign valid    = ((opcode == R_OPCODE)     || (opcode == I_OPCODE)     || (opcode == S_OPCODE)
                    || (opcode == B_OPCODE)     || (opcode == JAL_OPCODE)   || (opcode == JALR_OPCODE)
                    || (opcode == LUI_OPCODE)   || (opcode == AUIPC_OPCODE) || (opcode == SYSCALL_OPCODE)
                    || (opcode == CSR_OPCODE));

    assign invalid  = ~valid;

    assign instr_out    = instr_in;

endmodule

`endif
