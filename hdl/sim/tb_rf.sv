// Register file testbench
// Created:     2025-06-28
// Modified:    

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`timescale 1ns/1ps

module tb_rf
    #()();

    localparam RF_WIDTH = 32;
    localparam RF_DEPTH = 32;
    localparam QI_WIDTH = 6;

    logic clk;
    logic rst;
    
    logic [$clog2(RF_DEPTH)-1:0] rs1_addr;
    logic [$clog2(RF_DEPTH)-1:0] rs2_addr;
    logic [RF_WIDTH-1:0] rs1_data_out;
    logic [RF_WIDTH-1:0] rs2_data_out;
    logic [QI_WIDTH-1:0] rs1_qi_out;
    logic [QI_WIDTH-1:0] rs2_qi_out;

    logic reg_wr_en;
    logic qi_wr_en;
    logic [$clog2(RF_DEPTH)-1:0] rd_addr;
    logic [RF_WIDTH-1:0] reg_data_in;
    logic [QI_WIDTH-1:0] qi_data_in;

    rf #(
        .RF_WIDTH(RF_WIDTH),
        .RF_DEPTH(RF_DEPTH),
        .QI_WIDTH(QI_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rs1_data_out(rs1_data_out),
        .rs2_data_out(rs2_data_out),
        .rs1_qi_out(rs1_qi_out),
        .rs2_qi_out(rs2_qi_out),
        .reg_wr_en(reg_wr_en),
        .qi_wr_en(qi_wr_en),
        .rd_addr(rd_addr),
        .reg_data_in(reg_data_in),
        .qi_data_in(qi_data_in)
    );

    always #5   clk = ~clk;

    initial
    begin
        clk <= 1'b0;
        rst <= 1'b0;
        rs1_addr <= 'd0;
        rs2_addr <= 'd0;
        reg_wr_en <= 1'b0;
        qi_wr_en <= 1'b0;
        rd_addr <= 'd0;
        reg_data_in <= 'd0;
        qi_data_in <= 'd0;

        @(posedge clk);
        rst <= 1'b1;

        @(posedge clk);
        rst <= 1'b0;

        @(posedge clk);
        qi_wr_en <= 1'b1;
        rd_addr <= 'd2;
        qi_data_in <= 'd3;

        @(posedge clk);
        reg_wr_en <= 1'b1;
        qi_wr_en <= 1'b0;
        reg_data_in <= 'd446;

        @(posedge clk);
        rd_addr <= 'd3;
        reg_data_in <= 'd331;

        @(posedge clk);
        reg_wr_en <= 1'b0;
        qi_wr_en <= 1'b1;
        qi_data_in <= 'd5;
        rs1_addr <= 'd2;
        rs2_addr <= 'd3;

        @(posedge clk);
        qi_wr_en <= 1'b0;

        #100;
        $finish;
    end

endmodule
