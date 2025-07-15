// Double-Port Read-First RAM Module
// Created:     2025-07-14
// Modified:    2025-07-15

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

// Adapted from Vivado's language templates

`ifndef QU_MEM
`define QU_MEM

module ram_dp_rf #(
  parameter NB_COL = 4,                           // Specify number of columns (number of bytes)
  parameter COL_WIDTH = 8,                        // Specify column width (byte width, typically 8 or 9)
  parameter RAM_DEPTH = 1024,                     // Specify RAM depth (number of entries)
  parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE", // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
  parameter INIT_FILE = ""                        // Specify name/location of RAM initialization file if using one (leave blank if not)
) (
  input [clogb2(RAM_DEPTH-1)-1:0] addra,   // Port A address bus, width determined from RAM_DEPTH
  input [clogb2(RAM_DEPTH-1)-1:0] addrb,   // Port B address bus, width determined from RAM_DEPTH
  input [(NB_COL*COL_WIDTH)-1:0] dina,   // Port A RAM input data
  input [(NB_COL*COL_WIDTH)-1:0] dinb,   // Port B RAM input data
  input clka,                            // Clock
  input [NB_COL-1:0] wea,                // Port A write enable
  input [NB_COL-1:0] web,                // Port B write enable
  input ena,                             // Port A RAM Enable, for additional power savings, disable port when not in use
  input enb,                             // Port B RAM Enable, for additional power savings, disable port when not in use
  input rsta,                            // Port A output reset (does not affect memory contents)
  input rstb,                            // Port B output reset (does not affect memory contents)
  input regcea,                          // Port A output register enable
  input regceb,                          // Port B output register enable
  output valida,                         // Port A output valid flag
  output validb,                         // Port B output valid flag
  output [clogb2(RAM_DEPTH-1)-1:0] valida_addr,
  output [clogb2(RAM_DEPTH-1)-1:0] validb_addr,
  output [(NB_COL*COL_WIDTH)-1:0] douta, // Port A RAM output data
  output [(NB_COL*COL_WIDTH)-1:0] doutb  // Port B RAM output data
);

  reg [(NB_COL*COL_WIDTH)-1:0] BRAM [RAM_DEPTH-1:0];
  reg [(NB_COL*COL_WIDTH)-1:0] ram_data_a = {(NB_COL*COL_WIDTH){1'b0}};
  reg [(NB_COL*COL_WIDTH)-1:0] ram_data_b = {(NB_COL*COL_WIDTH){1'b0}};

  reg reg_valida;
  reg reg_validb;
  reg [clogb2(RAM_DEPTH-1)-1:0] reg_valida_addr;
  reg [clogb2(RAM_DEPTH-1)-1:0] reg_validb_addr;

  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  generate
    if (INIT_FILE != "") begin: use_init_file
      initial
        $readmemh(INIT_FILE, BRAM, 0, RAM_DEPTH-1);
    end else begin: init_bram_to_zero
      integer ram_index;
      initial
        for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
          BRAM[ram_index] = {(NB_COL*COL_WIDTH){1'b0}};
    end
  endgenerate

  always @(posedge clka)
    if (ena) begin
      ram_data_a <= BRAM[addra];
      reg_valida <= 1'b1;
      reg_valida_addr <= addra;
    end else begin
      reg_valida <= 1'b0;
      reg_valida_addr <= addra;
    end

  always @(posedge clka)
    if (enb) begin
      ram_data_b <= BRAM[addrb];
      reg_validb <= 1'b1;
      reg_validb_addr <= addrb;
    end else begin
      reg_validb <= 1'b0;
      reg_validb_addr <= addrb;
    end

  generate
  genvar i;
     for (i = 0; i < NB_COL; i = i+1) begin: byte_write
       always @(posedge clka)
         if (ena)
           if (wea[i])
             BRAM[addra][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= dina[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
       always @(posedge clka)
         if (enb)
           if (web[i])
             BRAM[addrb][(i+1)*COL_WIDTH-1:i*COL_WIDTH] <= dinb[(i+1)*COL_WIDTH-1:i*COL_WIDTH];
end
  endgenerate

  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign douta = ram_data_a;
       assign doutb = ram_data_b;
       assign valida = reg_valida;
       assign validb = reg_validb;
       assign valida_addr = reg_valida_addr;
       assign validb_addr = reg_validb_addr;

    end else begin: output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [(NB_COL*COL_WIDTH)-1:0] douta_reg = {(NB_COL*COL_WIDTH){1'b0}};
      reg [(NB_COL*COL_WIDTH)-1:0] doutb_reg = {(NB_COL*COL_WIDTH){1'b0}};

      reg reg_temp_valida = 0;
      reg reg_temp_validb = 0;

      reg [clogb2(RAM_DEPTH-1)-1:0] reg_temp_valida_addr = 'b0;
      reg [clogb2(RAM_DEPTH-1)-1:0] reg_temp_validb_addr = 'b0;

      reg buf_valida = 0;
      reg buf_validb = 0;

      reg [clogb2(RAM_DEPTH-1)-1:0] buf_valida_addr = 'b0;
      reg [clogb2(RAM_DEPTH-1)-1:0] buf_validb_addr = 'b0;

      always @(posedge clka)
        if (ena) begin
          reg_temp_valida <= 1'b1;
          reg_temp_valida_addr <= addra;
        end else begin
          reg_temp_valida <= 1'b0;
          reg_temp_valida_addr <= 'b0;
        end

      always @(posedge clka) begin
        if (rsta) begin
          douta_reg <= {(NB_COL*COL_WIDTH){1'b0}};
        end else if (regcea) begin
          douta_reg <= ram_data_a;
        end

        if (regcea) begin
          buf_valida <= reg_temp_valida;
          buf_valida_addr <= reg_temp_valida_addr;
        end else begin
          buf_valida <= 1'b0;
          buf_valida_addr <= 'b0;
        end 
      end

      always @(posedge clka) begin
        if (enb) begin
          reg_temp_validb <= 1'b1;
          reg_temp_validb_addr <= addrb;
        end else begin
          reg_temp_validb <= 1'b0;
          reg_temp_validb_addr <= 'b0;
        end
      end

      always @(posedge clka) begin
        if (rstb) begin
          doutb_reg <= {(NB_COL*COL_WIDTH){1'b0}};
        end else if (regceb) begin
          doutb_reg <= ram_data_b;
        end

        if (regceb) begin
          buf_validb <= reg_temp_validb;
          buf_validb_addr <= reg_temp_validb_addr;
        end else begin
          buf_validb <= 1'b0;
          buf_validb_addr <= 'b0;
        end
      end

      assign douta = douta_reg;
      assign doutb = doutb_reg;

      assign valida = buf_valida;
      assign validb = buf_validb;

      assign valida_addr = buf_valida_addr;
      assign validb_addr = buf_validb_addr;

    end
  endgenerate

  //  The following function calculates the address width based on specified RAM depth
  function integer clogb2;
    input integer depth;
      for (clogb2=0; depth>0; clogb2=clogb2+1)
        depth = depth >> 1;
  endfunction

endmodule

`endif


							
							