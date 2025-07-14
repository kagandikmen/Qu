// Load-store unit of The Qu Processor
// Created:     2025-07-14
// Modified:    

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_LDST_UNIT
`define QU_LDST_UNIT

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module ldst_unit
    #(
    )(
        input   logic [31:0] opd1,
        input   logic [31:0] opd2,

        output  logic [31:0] addr_out
    );

    assign addr_out = opd1 + opd2;

endmodule

`endif
