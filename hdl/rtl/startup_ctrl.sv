// Startup controller module
// Created:     2025-06-27
// Modified:    2025-07-01

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_STARTUP_CTRL
`define QU_STARTUP_CTRL

module startup_ctrl
    #()(
        input logic clk,
        input logic rst,

        input logic fifo_mp_rn_empty,

        output logic if_en,
        output logic id_en,
        output logic rn_en
    );

    logic [1:0] startup_initiated;
    logic if_en_buf;
    logic id_en_buf;
    logic rn_en_buf;

    always_ff @(posedge clk)
    begin
        startup_initiated[0] <= startup_initiated[1];
        startup_initiated[1] <= 1'b0;

        if_en_buf <= (if_en_buf || startup_initiated[1]) && !rst;
        id_en_buf <= (id_en_buf || startup_initiated[0]) && !rst;
        rn_en_buf <= (rn_en_buf || (!fifo_mp_rn_empty)) && !rst;

        if(rst)
        begin
            startup_initiated[0] <= 1'b0;
            startup_initiated[1] <= 1'b1;
        end
    end

    assign if_en = if_en_buf;
    assign id_en = id_en_buf;
    assign rn_en = rn_en_buf && !rst;

endmodule

`endif
