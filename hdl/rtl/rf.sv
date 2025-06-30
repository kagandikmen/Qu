// Register file of The Qu Processor
// Created:     2025-06-28
// Modified:    2025-06-30

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_RF
`define QU_RF

module rf
    #(
        parameter RF_WIDTH = 32,
        parameter RF_DEPTH = 128
    )(
        input logic clk,
        input logic rst,

        input logic [$clog2(RF_DEPTH)-1:0] rs1_addr,
        input logic [$clog2(RF_DEPTH)-1:0] rs2_addr,
        output logic [RF_WIDTH-1:0] rs1_data_out,
        output logic [RF_WIDTH-1:0] rs2_data_out,

        input logic wr_en,
        input logic [$clog2(RF_DEPTH)-1:0] rd_addr,
        input logic [RF_WIDTH-1:0] data_in
    );

    logic [RF_DEPTH-1:0][RF_WIDTH-1:0] rf;

    // write logic
    always_ff @(posedge clk)
    begin
        // data write logic
        if(wr_en)
        begin
            rf[rd_addr] <= data_in;
        end

        // reset logic
        if(rst)
        begin
            rf <= '{default: 'b0};
        end
    end

    // read logic
    always_comb
    begin
        rs1_data_out = rf[rs1_addr];
        rs2_data_out = rf[rs2_addr];
    end

endmodule

`endif
