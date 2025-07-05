// Busy table of The Qu Processor
// Created:     2025-06-30
// Modified:    2025-07-05

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_BUSY_TABLE
`define QU_BUSY_TABLE

module busy_table
    #(
        parameter PHY_RF_DEPTH = 128
    )(
        input   logic clk,
        input   logic rst,
        
        input   logic [$clog2(PHY_RF_DEPTH)-1:0] rd1_addr,
        output  logic rd1_out,

        input   logic [$clog2(PHY_RF_DEPTH)-1:0] rd2_addr,
        output  logic rd2_out,

        input   logic wr1_en,
        input   logic [$clog2(PHY_RF_DEPTH)-1:0] wr1_addr,
        input   logic wr1_in,

        input   logic wr2_en,
        input   logic [$clog2(PHY_RF_DEPTH)-1:0] wr2_addr,
        input   logic wr2_in
    );

    logic [PHY_RF_DEPTH-1:0] busy_table;

    logic wr_collide;

    assign wr_collide = wr1_en && wr2_en && (wr1_addr == wr2_addr) && (wr1_in != wr2_in);

    always_comb
    begin
        rd1_out = busy_table[rd1_addr];
        rd2_out = busy_table[rd2_addr];
    end

    always_ff @(posedge clk)
    begin
        if(wr1_en && !wr_collide)
        begin
            busy_table[wr1_addr] <= wr1_in;
        end

        if(wr2_en && !wr_collide)
        begin
            busy_table[wr2_addr] <= wr2_in;
        end

        if(rst)
        begin
            busy_table <= '{default: 'd0};
        end
    end
    
endmodule

`endif
