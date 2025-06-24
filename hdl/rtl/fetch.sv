// Fetch stage of the instruction pipeline
// Created:     2025-06-24
// Modified:    2025-06-24

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_FETCH
`define QU_FETCH

module fetch
    #(
        parameter INSTR_WIDTH = 32,
        parameter PMEM_INIT_FILE = "",
        parameter PC_WIDTH = 12,
        parameter PC_RESET_VAL = 0
    )(
        input logic clk,
        input logic rst,

        input logic branch,
        input logic jump,
        input logic exception,
        input logic stall,

        input logic [PC_WIDTH-1:0] pc_override_in,

        output logic [INSTR_WIDTH-1:0] instr,
        output logic [PC_WIDTH-1:0] pc
    );

    logic pc_override;
    logic [PC_WIDTH-1:0] pc_ctr_pc_out;
    logic [INSTR_WIDTH-1:0] pmem_douta;


    //
    //  program memory
    //

    ram_sp_rf #(
        .RAM_WIDTH(INSTR_WIDTH),
        .RAM_DEPTH(2**PC_WIDTH),
        .RAM_PERFORMANCE("LOW_LATENCY"),
        .INIT_FILE(PMEM_INIT_FILE)
    ) qu_pmem (
        .addra(pc_ctr_pc_out),
        .dina(),
        .clka(clk),
        .wea(),
        .ena(!stall),
        .rsta(),
        .regcea(),
        .douta(pmem_douta)
    );

    assign instr = pmem_douta;

    //
    //  pc counter
    //

    pc_ctr #(
        .PC_WIDTH(PC_WIDTH),
        .PC_INC(1),
        .PC_RESET_VAL(PC_RESET_VAL)
    ) qu_pc_ctr (
        .clk(clk),
        .rst(rst),
        .en(!stall),
        .pc_override(pc_override),
        .pc_in(pc_override_in),
        .pc_out(pc_ctr_pc_out)
    );

    assign pc_override = branch | jump | exception;
    assign pc = pc_ctr_pc_out;

endmodule

`endif
