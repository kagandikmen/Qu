// Busy table of The Qu Processor
// Created:     2025-06-30
// Modified:    

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
        
        // for reads from map stage
        input   logic [$clog2(PHY_RF_DEPTH)-1:0] rd1_addr,
        output  logic data1_out,

        // for reads from rename stage
        input   logic [$clog2(PHY_RF_DEPTH)-1:0] rd2_addr,
        output  logic data2_out,

        input   logic wr_en,
        input   logic [$clog2(PHY_RF_DEPTH)-1:0] wr_addr,
        input   logic data_in
    );

    logic [PHY_RF_DEPTH-1:0] busy_table;

    always_comb
    begin
        data1_out = busy_table[rd1_addr];
        data2_out = busy_table[rd2_addr];
    end

    always_ff @(posedge clk)
    begin
        if(rst)
        begin
            busy_table <= '{default: 'd0};
        end
        else if(wr_en)
        begin
            busy_table[wr_addr] <= data_in;
        end
    end
    
endmodule

`endif
