// FIFO module
// Created:     2025-06-23
// Modified:    2025-06-27

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_FIFO
`define QU_FIFO

module fifo
    #(
        parameter FIFO_WIDTH = 32,
        parameter FIFO_DEPTH = 8
    )(
        input logic clk,
        input logic rst,

        input logic rd_en,
        output logic [FIFO_WIDTH-1:0] data_out,

        input logic wr_en,
        input logic [FIFO_WIDTH-1:0] data_in,

        output logic empty,
        output logic almost_empty,

        output logic full,
        output logic almost_full
    );

    localparam FIFO_ADDR_WIDTH = $clog2(FIFO_DEPTH);

    logic empty_buf, almost_empty_buf;
    logic full_buf, almost_full_buf;
    logic [FIFO_ADDR_WIDTH-1:0] rd_ptr, wr_ptr;
    logic [FIFO_DEPTH-1:0][FIFO_WIDTH-1:0] fifo;

    always_ff @(posedge clk)
    begin
        data_out <= 'b0;
        if(rst)
        begin
            rd_ptr <= 'b0;
            wr_ptr <= 'b0;
            for(int i=0; i<FIFO_DEPTH;i++) fifo[i] <= 'b0;
        end
        else
        begin
            if(rd_en && !empty_buf)
            begin
                rd_ptr <= rd_ptr + 1;
                data_out <= fifo[rd_ptr];
            end
            
            if(wr_en && !full_buf)
            begin
                wr_ptr <= wr_ptr + 1;
                fifo[wr_ptr] <= data_in;
            end
        end
    end

    always_comb
    begin
        empty_buf = 1'b0;   
        almost_empty_buf = 1'b0;

        full_buf = 1'b0;    
        almost_full_buf = 1'b0;

        if(rd_ptr == wr_ptr) empty_buf = 1'b1;
        if(rd_ptr+1 == wr_ptr) almost_empty_buf = 1'b1;

        if(rd_ptr == wr_ptr+1) full_buf = 1'b1;
        if(rd_ptr == wr_ptr+2) almost_full_buf = 1'b1;
    end

    assign empty = empty_buf;
    assign almost_empty = almost_empty_buf;

    assign full = full_buf;
    assign almost_full = almost_full_buf;

endmodule

`endif
