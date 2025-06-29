// Register file of The Qu Processor
// Created:     2025-06-28
// Modified:    

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_RF
`define QU_RF

module rf
    #(
        parameter RF_WIDTH = 32,
        parameter RF_DEPTH = 32,
        parameter QI_WIDTH = 6
    )(
        input logic clk,
        input logic rst,

        input logic [$clog2(RF_DEPTH)-1:0] rs1_addr,
        input logic [$clog2(RF_DEPTH)-1:0] rs2_addr,
        output logic [RF_WIDTH-1:0] rs1_data_out,
        output logic [RF_WIDTH-1:0] rs2_data_out,
        output logic [QI_WIDTH-1:0] rs1_qi_out,
        output logic [QI_WIDTH-1:0] rs2_qi_out,

        input logic reg_wr_en,
        input logic qi_wr_en,
        input logic [$clog2(RF_DEPTH)-1:0] rd_addr,
        input logic [RF_WIDTH-1:0] reg_data_in,
        input logic [QI_WIDTH-1:0] qi_data_in
    );

    typedef struct packed {
        reg [QI_WIDTH-1:0] qi;
        reg [RF_WIDTH-1:0] data;
    } reg_t;

    reg_t [RF_DEPTH-1:0] rf;

    // write logic
    always_ff @(posedge clk)
    begin
        // qi write logic
        if(qi_wr_en)
        begin
            rf[rd_addr].qi <= qi_data_in;
        end

        // data write logic
        if(reg_wr_en)
        begin
            rf[rd_addr].qi <= 'b0;
            rf[rd_addr].data <= reg_data_in;
        end

        // reset logic
        if(rst)
        begin
            for(int i=0; i<RF_DEPTH; i=i+1)
            begin
                rf[i].qi <= 'b0;
                rf[i].data <= 'b0;
            end
        end

        // address x0 is always zero
        rf[0].qi <= 'b0;
        rf[0].data <= 'b0;
    end

    // read logic
    always_comb
    begin
        rs1_data_out = rf[rs1_addr].data;
        rs1_qi_out = rf[rs1_addr].qi;

        rs2_data_out = rf[rs2_addr].data;
        rs2_qi_out = rf[rs2_addr].qi;
    end

endmodule

`endif
