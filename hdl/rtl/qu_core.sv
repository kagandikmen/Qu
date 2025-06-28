// The Qu Processor CPU core module
// Created:     2025-06-27
// Modified:    2025-06-28

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_CORE
`define QU_CORE

import qu_common::*;
import qu_uop::*;

module qu_core
    #(
        parameter PMEM_INIT_FILE = "",
        parameter INSTR_WIDTH = QU_INSTR_WIDTH,
        parameter PC_WIDTH = QU_PC_WIDTH
    )(
        input logic clk,
        input logic rst,
        
        input logic branch,
        input logic jump,
        input logic exception,
        input logic stall,
        input logic [PC_WIDTH-1:0] pc_override,

        input logic if_stall,
        input logic id_stall,

        output logic nop,
        output logic invalid,
        output uop_t uop_out
    );

    logic fetch_branch_in;
    logic fetch_jump_in;
    logic fetch_exception_in;
    logic fetch_stall_in;
    logic [PC_WIDTH-1:0] fetch_pc_override_in;
    logic [INSTR_WIDTH-1:0] fetch_instr_out;
    logic [PC_WIDTH-1:0] fetch_pc_out;

    logic [INSTR_WIDTH-1:0] decode_instr_in;
    logic decode_nop_out;
    logic decode_invalid_out;
    uop_t decode_uop_out;

    logic fifo_rd_en_in;
    logic [INSTR_WIDTH-1:0] fifo_data_out;
    logic fifo_wr_en_in;
    logic [INSTR_WIDTH-1:0] fifo_data_in;
    logic fifo_empty_out;
    logic fifo_full_out;

    logic startup_ctrl_if_en_out;
    logic startup_ctrl_id_en_out;

    fetch #(
        .INSTR_WIDTH(INSTR_WIDTH),
        .PMEM_INIT_FILE(PMEM_INIT_FILE),
        .PC_WIDTH(PC_WIDTH),
        .PC_RESET_VAL(QU_PC_RESET_VAL)
    ) qu_fetch (
        .clk(clk),
        .rst(rst),
        .branch(fetch_branch_in),
        .jump(fetch_jump_in),
        .exception(fetch_exception_in),
        .stall(fetch_stall_in),
        .pc_override_in(fetch_pc_override_in),
        .instr(fetch_instr_out),
        .pc(fetch_pc_out)
    );

    fifo #(
        .FIFO_WIDTH(INSTR_WIDTH),
        .FIFO_DEPTH(4)
    ) qu_fifo_if_id (
        .clk(clk),
        .rst(rst),
        .rd_en(fifo_rd_en_in),
        .data_out(fifo_data_out),
        .wr_en(fifo_wr_en_in),
        .data_in(fifo_data_in),
        .empty(fifo_empty_out),
        .almost_empty(),
        .full(fifo_full_out),
        .almost_full()
    );

    decode #(
        .INSTR_WIDTH(INSTR_WIDTH)
    ) qu_decode (
        .instr_in(decode_instr_in),
        .nop(decode_nop_out),
        .invalid(decode_invalid_out),
        .uop_out(decode_uop_out)
    );

    startup_ctrl qu_startup_ctrl (
        .clk(clk),
        .rst(rst),
        .if_en(startup_ctrl_if_en_out),
        .id_en(startup_ctrl_id_en_out)
    );
    
    assign fetch_branch_in = branch;
    assign fetch_jump_in = jump;
    assign fetch_exception_in = exception;
    assign fetch_stall_in = stall || if_stall || fifo_full_out;
    assign fetch_pc_override_in = pc_override;
    
    assign fifo_rd_en_in = !stall && !id_stall && !fifo_empty_out && startup_ctrl_id_en_out;
    assign fifo_wr_en_in = !fetch_stall_in && startup_ctrl_if_en_out;
    assign fifo_data_in = fetch_instr_out;
    
    assign decode_instr_in = fifo_data_out;
    assign nop = decode_nop_out;
    assign invalid = decode_invalid_out;
    assign uop_out = decode_uop_out;

endmodule

`endif
