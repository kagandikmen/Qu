// Retire stage of The Qu Processor
// Created:     2025-07-06
// Modified:    2025-07-15

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_RETIRE
`define QU_RETIRE

`include "../lib/qu_common.svh"
`include "../lib/qu_uop.svh"

import qu_common::*;
import qu_uop::*;

module retire 
    #()(
        input   logic clk,
        input   logic rst,

        // FIFO interface
        input   phy_rf_data_t value_in,
        input   logic comp_result_in,
        input   res_st_cell_t op_in,

        // register file interface
        output  logic phy_rf_wr_en,
        output  phy_rf_addr_t phy_rf_wr_addr,
        output  phy_rf_data_t phy_rf_wr_data,

        // map stage interface
        output  phy_rf_addr_t phyreg_renamed_free_reg_addr,

        // rename stage interface
        output  logic busy_table_wr_en,
        output  logic [PHY_RF_ADDR_WIDTH-1:0] busy_table_wr_addr,
        output  logic busy_table_wr_data,
        output  rob_addr_t rob_tail_ptr,
        input   logic rob_incr_tail_ptr,
        output  logic rob_full,

        // retire broadcast
        output  logic retire_en,
        output  rob_addr_t retire_rob_addr,
        output  phy_rf_data_t retire_value,

        // mispredicted branch
        output  logic mispredicted_branch,
        output  pc_t pc_to_jump,

        output  logic [3:0] dmem_wr_en_out,
        output  logic dmem_rd_en_out,
        output  logic [31:0] dmem_addr_out,
        output  logic [31:0] dmem_data_out,
        input   logic dmem_valid_in,
        input   logic [$clog2(MEM_DEPTH)-1:0] dmem_valid_addr_in,
        input   logic [31:0] dmem_data_in
    );

    rob_addr_t head_ptr;
    rob_addr_t tail_ptr;

    logic [$bits(rob_addr_t):0] head_ptr_padded;
    logic [$bits(rob_addr_t):0] tail_ptr_padded;

    logic rob_wr1_en;
    rob_addr_t rob_wr1_addr;
    rob_cell_t rob_wr1_in;

    logic rob_wr2_en;
    rob_addr_t rob_wr2_addr;
    rob_cell_t rob_wr2_in;

    rob_addr_t rob_rd1_addr;
    rob_cell_t rob_rd1_out;

    rob_addr_t rob_rd2_addr;
    rob_cell_t rob_rd2_out;

    logic op_in_valid;

    logic retire_en_buf;
    logic [3:0] dmem_wr_en_out_buf;
    logic dmem_rd_en_out_buf;
    logic [31:0] dmem_addr_out_buf;
    logic [31:0] dmem_data_out_buf;

    phy_rf_addr_t phyreg_renamed_free_reg_addr_buf;

    assign op_in_valid = op_in.op.optype[0];

    assign rob_wr1_en = op_in_valid;
    assign rob_wr1_addr = op_in.rob_addr;
    assign rob_wr1_in.value = (op_in.op.optype == OPTYPE_STORE) ? op_in.vk : value_in;

    // Currently, all branches are assumed not taken. This will be improved later.
    assign rob_wr1_in.mispredicted_branch = (op_in.op.optype == OPTYPE_BRANCH) && comp_result_in;
    
    assign rob_wr1_in.phyreg_old = op_in.phyreg_old;
    assign rob_wr1_in.store = (op_in.op.optype == OPTYPE_STORE);
    assign rob_wr1_in.load = (op_in.op.optype == OPTYPE_LOAD);
    assign rob_wr1_in.ldst_funct3 = op_in.op.alu_input_sel;
    assign rob_wr1_in.dest = (op_in.op.optype == OPTYPE_STORE) ? value_in : {'b0, op_in.dest};
    assign rob_wr1_in.state = ROB_STATE_PENDING;

    assign rob_tail_ptr = tail_ptr;
    assign retire_en = retire_en_buf;
    assign rob_full = (tail_ptr + 1 == head_ptr 
                    || tail_ptr + 2 == head_ptr
                    || tail_ptr == head_ptr + 5
                    || tail_ptr == head_ptr + 6);   // TODO: improve

    assign dmem_wr_en_out = dmem_wr_en_out_buf;
    assign dmem_rd_en_out = dmem_rd_en_out_buf;
    assign dmem_addr_out = dmem_addr_out_buf;
    assign dmem_data_out = dmem_data_out_buf;

    assign phyreg_renamed_free_reg_addr = phyreg_renamed_free_reg_addr_buf;

    rob qu_rob (
        .clk(clk),
        .rst(rst),
        .wr1_en(rob_wr1_en),
        .wr1_addr(rob_wr1_addr),
        .wr1_in(rob_wr1_in),
        .wr2_en(rob_wr2_en),
        .wr2_addr(rob_wr2_addr),
        .wr2_in(rob_wr2_in),
        .rd1_addr(rob_rd1_addr),
        .rd1_out(rob_rd1_out),
        .rd2_addr(rob_rd2_addr),
        .rd2_out(rob_rd2_out)
    );

    always_ff @(posedge clk)
    begin
        if(rob_incr_tail_ptr)
        begin
            tail_ptr <= (tail_ptr == ROB_DEPTH-1) ? 'd1 : tail_ptr + 1;
        end

        if(retire_en_buf)
        begin
            head_ptr <= (head_ptr == ROB_DEPTH-1) ? 'd1 : head_ptr + 1;
        end

        if(rst)
        begin
            head_ptr <= 'd1;
            tail_ptr <= 'd1;
        end
    end

    always_comb
    begin
        rob_rd1_addr = head_ptr;

        if(rob_rd1_out.state == ROB_STATE_PENDING)
        begin

            mispredicted_branch = rob_rd1_out.mispredicted_branch;
            phyreg_renamed_free_reg_addr_buf = rob_rd1_out.phyreg_old;

            if(rob_rd1_out.store)
            begin
                case(rob_rd1_out.ldst_funct3)
                    FUNCT3_SB:
                        dmem_wr_en_out_buf = 4'b0001;
                    FUNCT3_SH:
                        dmem_wr_en_out_buf = 4'b0011;
                    FUNCT3_SW:
                        dmem_wr_en_out_buf = 4'b1111;
                    default:
                        dmem_wr_en_out_buf = 4'b0000;
                endcase
            end

            if(rob_rd1_out.load && dmem_valid_in && dmem_valid_addr_in == rob_rd1_out.dest.dmem_dest)
            begin
                dmem_rd_en_out_buf = 1'b0;
                phy_rf_wr_en = 1'b1;
                busy_table_wr_en = 1'b1;
                retire_en_buf = 1'b1;

                case(rob_rd1_out.ldst_funct3)
                    FUNCT3_LW:
                        phy_rf_wr_data = dmem_data_in;
                    FUNCT3_LHU:
                        phy_rf_wr_data = {16'b0, dmem_data_in[15:0]};
                    FUNCT3_LH:
                        phy_rf_wr_data = {{16{dmem_data_in[15]}}, dmem_data_in[15:0]};
                    FUNCT3_LBU:
                        phy_rf_wr_data = {24'b0, dmem_data_in[7:0]};
                    FUNCT3_LB:
                        phy_rf_wr_data = {{24{dmem_data_in[7]}}, dmem_data_in[7:0]};
                    default:
                        phy_rf_wr_data = 'b0;
                endcase
                
            end
            else if(rob_rd1_out.load && !dmem_valid_in)
            begin
                dmem_rd_en_out_buf = 1'b1;
                phy_rf_wr_en = 1'b0;
                busy_table_wr_en = 1'b0;
                retire_en_buf = 1'b0;
                phy_rf_wr_data = 'd0;
            end
            else
            begin
                dmem_rd_en_out_buf = 1'b0;
                phy_rf_wr_en = (rob_rd1_out.dest != 'd0 && !rob_rd1_out.store);
                busy_table_wr_en = (rob_rd1_out.dest != 'd0 && !rob_rd1_out.store);
                retire_en_buf = (rob_rd1_out.dest != 'd0);
                phy_rf_wr_data = rob_rd1_out.value;
            end
        end
        else
        begin
            mispredicted_branch = 'b0;
            dmem_wr_en_out_buf = 'b0;
            dmem_rd_en_out_buf = 'b0;
            phy_rf_wr_en = 'b0;
            busy_table_wr_en = 'b0;
            phyreg_renamed_free_reg_addr_buf = 'b0;
            retire_en_buf = 'b0;
            phy_rf_wr_data = rob_rd1_out.value;
        end

        pc_to_jump = rob_rd1_out.value;

        dmem_addr_out_buf = rob_rd1_out.store ? rob_rd1_out.dest.dmem_dest : rob_rd1_out.value;
        dmem_data_out_buf = rob_rd1_out.value;
        
        phy_rf_wr_addr = rob_rd1_out.dest.phy_rf_padded_dest.dest;

        busy_table_wr_addr = rob_rd1_out.dest.phy_rf_padded_dest.dest;
        busy_table_wr_data = 1'b0;

        retire_rob_addr = head_ptr;
        retire_value = rob_rd1_out.value;

        rob_wr2_en = (rob_rd1_out.state == ROB_STATE_PENDING && retire_en_buf);
        rob_wr2_addr = head_ptr;
        rob_wr2_in = rob_rd1_out;
        rob_wr2_in.state = ROB_STATE_RETIRED;
    end

endmodule

`endif
