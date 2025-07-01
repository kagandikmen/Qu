// Map stage of The Qu Processor
// Created:     2025-06-29
// Modified:    2025-07-01

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_MAP
`define QU_MAP

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module map
    #(
        parameter LOG_RF_DEPTH = 32,
        parameter PHY_RF_DEPTH = 128
    )(
        input   logic clk,
        input   logic rst,
        input   logic en,

        input   uop_t uop_in,
        output  uop_t uop_out,

        output  logic full,

        // busy table interface
        output  logic busy_table_wr_en,
        output  logic [$clog2(PHY_RF_DEPTH)-1:0] busy_table_wr_addr,
        output  logic busy_table_data_out
    );

    localparam LOG_RF_ADDR_WIDTH = $clog2(LOG_RF_DEPTH);
    localparam PHY_RF_ADDR_WIDTH = $clog2(PHY_RF_DEPTH);

    logic [PHY_RF_DEPTH-1:0] phyreg_renamed;
    logic [LOG_RF_DEPTH-1:0][PHY_RF_ADDR_WIDTH-1:0] rename_table;

    uop_t uop_out_buf;

    logic [LOG_RF_ADDR_WIDTH-1:0] rd_in, rs2_in, rs1_in;
    logic rd_valid_in, rs2_valid_in, rs1_valid_in;

    logic [PHY_RF_ADDR_WIDTH-1:0] next_to_assign [2:0];
    logic [2:0] rename_executed;

    int num_free = 0;
    int found = 0; 

    assign rd_in = uop_in.uop_ic.rd;
    assign rd_valid_in = uop_in.uop_ic.rd_valid;

    assign rs1_in = uop_in.uop_ic.rs1;
    assign rs1_valid_in = uop_in.uop_ic.rs1_valid;

    assign rs2_in = uop_in.uop_ic.rs2;
    assign rs2_valid_in = uop_in.uop_ic.rs2_valid;

    assign uop_out = uop_out_buf;

    always_comb
    begin

        //
        // next_to_assign logic
        //

        found = 0;

        next_to_assign = '{default: 'b0};

        for(int i=1; i<PHY_RF_DEPTH; i++)
        begin
            if((phyreg_renamed[i] == 1'b0))
            begin
                next_to_assign[found] = i;
                found++;

                if(found == 3)
                    break;
            end
        end

        //
        // rename logicqi_list
        //

        // rs2
        if(rename_table[rs2_in] == 'b0)
        begin
            if(rs1_in == rs2_in)
            begin
                uop_out_buf.uop_ic.rs2 = next_to_assign[1];
                rename_executed[1] = 1'b1;
                rename_executed[2] = 1'b0;
            end
            else
            begin
                uop_out_buf.uop_ic.rs2 = next_to_assign[2];
                rename_executed[2] = 1'b1;
            end
        end
        else
        begin
            uop_out_buf.uop_ic.rs2 = rename_table[rs2_in];
            rename_executed[2] = 1'b0;
        end

        // rs1
        if(rename_table[rs1_in] == 'b0)
        begin
            uop_out_buf.uop_ic.rs1 = next_to_assign[1];
            rename_executed[1] = 1'b1;
        end
        else
        begin
            uop_out_buf.uop_ic.rs1 = rename_table[rs1_in];
            rename_executed[1] = 1'b0;
        end

        // rd
        uop_out_buf.uop_ic.rd = next_to_assign[0];
        rename_executed[0] = 1'b1;
        
        //
        // uop_out logic
        //

        uop_out_buf.uop_ic.optype = uop_in.uop_ic.optype;
        uop_out_buf.uop_ic.alu_cu_input_opd3_opd4_sel = uop_in.uop_ic.alu_cu_input_opd3_opd4_sel;
        uop_out_buf.uop_ic.alu_subunit_res_sel = uop_in.uop_ic.alu_subunit_res_sel;
        uop_out_buf.uop_ic.alu_subunit_op_sel = uop_in.uop_ic.alu_subunit_op_sel;
        uop_out_buf.uop_ic.rd_valid = uop_in.uop_ic.rd_valid;
        uop_out_buf.uop_ic.rs1_valid = uop_in.uop_ic.rs1_valid;
        uop_out_buf.uop_ic.rs2_valid = uop_in.uop_ic.rs2_valid;
        uop_out_buf.uop_ic.imm_valid = uop_in.uop_ic.imm_valid;
        uop_out_buf.uop_ic.imm = uop_in.uop_ic.imm;

        //
        // full signal logic
        //

        num_free = 0;

        for(int i=0; i<PHY_RF_DEPTH; i=i+1)
        begin
            if(phyreg_renamed[i] == 1'b0)
                num_free++;
        end

        if(num_free < 3) 
            full = 1'b1;
        else
            full = 1'b0;

        //
        // busy table logic
        //

        busy_table_wr_en = en;
        busy_table_wr_addr = uop_out_buf.uop_ic.rd;
        busy_table_data_out = 1'b1;
    end

    always_ff @(posedge clk)
    begin

        if(rst)
        begin
            for(int i=0; i<PHY_RF_DEPTH; i=i+1)
            begin
                phyreg_renamed[i] <= 1'b0;
            end

            for(int i=0; i<LOG_RF_DEPTH; i=i+1)
            begin
                rename_table[i] <= 1'b0;
            end
        end
        else if(en)
        begin
            if(rename_executed[2])
            begin
                rename_table[rs2_in] <= next_to_assign[2];
                phyreg_renamed[next_to_assign[2]] <= 1'b1;
            end

            if(rename_executed[1])
            begin
                rename_table[rs1_in] <= next_to_assign[1];
                phyreg_renamed[next_to_assign[1]] <= 1'b1;
            end
            
            if(rename_executed[0])
            begin
                rename_table[rd_in]  <= next_to_assign[0];
                phyreg_renamed[next_to_assign[0]] <= 1'b1;
            end
        end
    end

endmodule

`endif
