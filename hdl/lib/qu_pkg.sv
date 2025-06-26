// Common RTL library for The Qu Processor
// Created:     2025-06-26
// Modified:    

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_PKG
`define QU_PKG

package qu_pkg;

    typedef enum logic [6:0] {
        R_OPCODE        = 7'b0110011,
        I_OPCODE        = 7'b0000011,
        S_OPCODE        = 7'b0100011,  
        B_OPCODE        = 7'b1100011,
        JAL_OPCODE      = 7'b1101111,
        JALR_OPCODE     = 7'b1100111,
        LUI_OPCODE      = 7'b0110111,
        AUIPC_OPCODE    = 7'b0010111,
        SYSCALL_OPCODE  = 7'b1110011,
        CSR_OPCODE      = 7'b1110011
    } opcode_t;

endpackage

`endif
