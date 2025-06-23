// PC Counter
// Created:     2025-06-23
// Modified:    

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_PC_CTR
`define QU_PC_CTR

module pc_ctr
    #(
        parameter PC_WIDTH = 32,
        parameter PC_INC = 1,
        parameter PC_RESET_VAL = 0
    )(
        input logic clk,
        input logic rst,

        input logic pc_override,
        input logic [PC_WIDTH-1:0] pc_in,

        output logic [PC_WIDTH-1:0] pc_out
    );

    logic [PC_WIDTH-1:0] pc_reg;

    always_ff @(posedge clk)
    begin
        pc_reg <= pc_reg + PC_INC;

        if(pc_override) pc_reg <= pc_in;
        
        if(rst) pc_reg <= PC_RESET_VAL;
    end

    assign pc_out = pc_reg;

endmodule

`endif