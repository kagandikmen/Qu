// Testbench for the load-store unit
// Created:     2025-07-14
// Modified:    

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`timescale 1ns/1ps

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module tb_ldst_unit
    #()();

    logic [31:0] opd1;
    logic [31:0] opd2;

    logic [31:0] addr_out;

    ldst_unit dut (
        .opd1(opd1),
        .opd2(opd2),
        .addr_out(addr_out)
    );

    initial
    begin
        opd1 <= 'd0;
        opd2 <= 'd0;

        #5;
        opd1 <= 'd5;
        opd2 <= 'd6;

        #5;
        opd1 <= -'d5;
        opd2 <= 'd6;

        #5;
        opd1 <= 'd5;
        opd2 <= -'d6;

        #5;
        opd1 <= -'d5;
        opd2 <= -'d6;

        #50;
        $finish;
    end
endmodule
