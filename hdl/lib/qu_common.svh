// Common RTL library for The Qu Processor
// Created:     2025-06-26
// Modified:    2025-07-12

// Copyright (c) 2025 Kagan Dikmen
// SPDX-License-Identifier: MIT
// See LICENSE for details

`ifndef QU_COMMON
`define QU_COMMON

package qu_common;

    //
    //  general parameters
    //

    parameter int QU_INSTR_WIDTH = 32;
    parameter int QU_PC_WIDTH = 12;
    parameter int QU_PC_RESET_VAL = 0;

    parameter int RES_ST_DEPTH = 32;
    parameter int RES_ST_OP_WIDTH = 17;
    parameter int RES_ST_ADDR_WIDTH = $clog2(RES_ST_DEPTH);
    parameter int RES_ST_VDATA_WIDTH = 32;
    parameter int RES_ST_ADATA_WIDTH = 12;

    parameter int LOG_RF_DEPTH = 32;
    parameter int LOG_RF_WIDTH = 32;

    parameter int PHY_RF_DEPTH = 128;
    parameter int PHY_RF_ADDR_WIDTH = $clog2(PHY_RF_DEPTH);

    parameter int ROB_DEPTH = 8;
    parameter int ROB_ADDR_WIDTH = $clog2(ROB_DEPTH);

    //
    //  funct3 parameters
    //

    parameter logic [2:0] FUNCT3_LB  = 3'b000;
    parameter logic [2:0] FUNCT3_LH  = 3'b001;
    parameter logic [2:0] FUNCT3_LW  = 3'b010;
    parameter logic [2:0] FUNCT3_LBU = 3'b100;
    parameter logic [2:0] FUNCT3_LHU = 3'b101;

    parameter logic [2:0] FUNCT3_FENCE   = 3'b000;
    parameter logic [2:0] FUNCT3_FENCEI = 3'b001;

    parameter logic [2:0] FUNCT3_ADDI    = 3'b000;
    parameter logic [2:0] FUNCT3_SLLI    = 3'b001;
    parameter logic [2:0] FUNCT3_SLTI    = 3'b010;
    parameter logic [2:0] FUNCT3_SLTIU   = 3'b011;
    parameter logic [2:0] FUNCT3_XORI    = 3'b100;
    parameter logic [2:0] FUNCT3_SRLI    = 3'b101;
    parameter logic [2:0] FUNCT3_SRAI    = 3'b101;
    parameter logic [2:0] FUNCT3_ORI     = 3'b110;
    parameter logic [2:0] FUNCT3_ANDI    = 3'b111;

    parameter logic [2:0] FUNCT3_SB  = 3'b000;
    parameter logic [2:0] FUNCT3_SH  = 3'b001;
    parameter logic [2:0] FUNCT3_SW  = 3'b010;

    parameter logic [2:0] FUNCT3_ADD     = 3'b000;
    parameter logic [2:0] FUNCT3_SUB     = 3'b000;
    parameter logic [2:0] FUNCT3_SLL     = 3'b001;
    parameter logic [2:0] FUNCT3_SLT     = 3'b010;
    parameter logic [2:0] FUNCT3_SLTU    = 3'b011;
    parameter logic [2:0] FUNCT3_XOR     = 3'b100;
    parameter logic [2:0] FUNCT3_SRL     = 3'b101;
    parameter logic [2:0] FUNCT3_SRA     = 3'b101;
    parameter logic [2:0] FUNCT3_OR      = 3'b110;
    parameter logic [2:0] FUNCT3_AND     = 3'b111;

    parameter logic [2:0] FUNCT3_BEQ     = 3'b000;
    parameter logic [2:0] FUNCT3_BNE     = 3'b001;
    parameter logic [2:0] FUNCT3_BLT     = 3'b100;
    parameter logic [2:0] FUNCT3_BGE     = 3'b101;
    parameter logic [2:0] FUNCT3_BLTU    = 3'b110;
    parameter logic [2:0] FUNCT3_BGEU    = 3'b111;

    parameter logic [2:0] FUNCT3_JALR    = 3'b000;

    parameter logic [2:0] FUNCT3_ECALL   = 3'b000;
    parameter logic [2:0] FUNCT3_EBREAK  = 3'b000;

    parameter logic [2:0] FUNCT3_CSRRW   = 3'b001;
    parameter logic [2:0] FUNCT3_CSRRS   = 3'b010;
    parameter logic [2:0] FUNCT3_CSRRC   = 3'b011;
    parameter logic [2:0] FUNCT3_CSRRWI  = 3'b101;
    parameter logic [2:0] FUNCT3_CSRRSI  = 3'b110;
    parameter logic [2:0] FUNCT3_CSRRCI  = 3'b111;

    //
    //  funct7 parameters
    //
    
    parameter logic [6:0] FUNCT7_SLLI    = 7'b0000000;
    parameter logic [6:0] FUNCT7_SRLI    = 7'b0000000;
    parameter logic [6:0] FUNCT7_SRAI    = 7'b0100000;

    parameter logic [6:0] FUNCT7_ADD     = 7'b0000000;
    parameter logic [6:0] FUNCT7_SUB     = 7'b0100000;
    parameter logic [6:0] FUNCT7_SLL     = 7'b0000000; 
    parameter logic [6:0] FUNCT7_SLT     = 7'b0000000;
    parameter logic [6:0] FUNCT7_SLTU    = 7'b0000000;
    parameter logic [6:0] FUNCT7_XOR     = 7'b0000000;
    parameter logic [6:0] FUNCT7_SRL     = 7'b0000000;
    parameter logic [6:0] FUNCT7_SRA     = 7'b0100000;
    parameter logic [6:0] FUNCT7_OR      = 7'b0000000;
    parameter logic [6:0] FUNCT7_AND     = 7'b0000000;

    //
    //  syscall immediates
    //
    
    parameter logic [11:0] IMM_ECALL    = 12'b000000000000;
    parameter logic [11:0] IMM_EBREAK   = 12'b000000000001;

    //
    //  opcode parameters
    //

    parameter logic [6:0] R_OPCODE        = 7'b0110011;
    parameter logic [6:0] I_OPCODE        = 7'b0010011;
    parameter logic [6:0] LOAD_OPCODE     = 7'b0000011;
    parameter logic [6:0] S_OPCODE        = 7'b0100011;  
    parameter logic [6:0] B_OPCODE        = 7'b1100011;
    parameter logic [6:0] JAL_OPCODE      = 7'b1101111;
    parameter logic [6:0] JALR_OPCODE     = 7'b1100111;
    parameter logic [6:0] LUI_OPCODE      = 7'b0110111;
    parameter logic [6:0] AUIPC_OPCODE    = 7'b0010111;
    parameter logic [6:0] SYSCALL_OPCODE  = 7'b1110011;
    parameter logic [6:0] CSR_OPCODE      = 7'b1110011;
    parameter logic [6:0] FENCE_OPCODE    = 7'b0001111;

    //
    //  type definitions
    //

    typedef logic [QU_INSTR_WIDTH-1:0] instr_t;

    typedef logic [6:0] opcode_t;

    typedef logic [2:0] funct3_t;
    typedef logic [6:0] funct7_t;

    typedef logic [4:0] reg_addr_t;

    typedef logic [11:0] imm12_t;
    typedef logic [12:0] imm13_t;
    typedef logic [20:0] imm21_t;
    typedef logic [31:0] imm32_t;

    typedef struct packed {
        funct7_t funct7;
        reg_addr_t rs2;
        reg_addr_t rs1;
        funct3_t funct3;
        reg_addr_t rd;
        opcode_t opcode;
    } r_instr_t;

    typedef struct packed {
        imm12_t imm12;
        reg_addr_t rs1;
        funct3_t funct3;
        reg_addr_t rd;
        opcode_t opcode;
    } i_instr_t;

    typedef struct packed {
        imm12_t imm12;
        reg_addr_t rs2;
        reg_addr_t rs1;
        funct3_t funct3;
        opcode_t opcode;
    } s_instr_t;

    typedef struct packed {
        imm13_t imm13;
        reg_addr_t rs2;
        reg_addr_t rs1;
        funct3_t funct3;
        opcode_t opcode;
    } b_instr_t;

    typedef struct packed {
        imm32_t imm32;
        reg_addr_t rd;
        opcode_t opcode;
    } u_instr_t;

    typedef struct packed {
        imm21_t imm21;
        reg_addr_t rd;
        opcode_t opcode;
    } uj_instr_t;

    typedef logic [PHY_RF_ADDR_WIDTH-1:0] phy_rf_addr_t;
    typedef logic [31:0] phy_rf_data_t;

    parameter logic [1:0] ROB_STATE_EMPTY = 2'b00;
    parameter logic [1:0] ROB_STATE_RETIRED = 2'b01;
    parameter logic [1:0] ROB_STATE_EXECUTE = 2'b10;
    parameter logic [1:0] ROB_STATE_PENDING = 2'b11;

    typedef logic [ROB_ADDR_WIDTH-1:0] rob_addr_t;

    typedef struct packed {
        logic [31:0] value;
        logic [PHY_RF_ADDR_WIDTH-1:0] dest;
        logic [1:0] state;
    } rob_cell_t;

    typedef logic [RES_ST_VDATA_WIDTH-1:0] res_st_vdata_t;
    typedef logic [RES_ST_ADATA_WIDTH-1:0] res_st_adata_t;
    typedef logic [RES_ST_ADDR_WIDTH-1:0] res_st_addr_t;
    
    typedef struct packed {
        logic imm_valid;
        logic rs2_valid;
        logic rs1_valid;
        logic rd_valid;
        logic [3:0] alu_subunit_op_sel;
        logic [1:0] alu_subunit_res_sel;
        logic alu_cu_input_sel;
        logic [2:0] alu_input_sel;
        logic [2:0] optype;
    } res_st_op_t;

    typedef struct packed {
        rob_addr_t rob_addr;
        phy_rf_addr_t dest;
        res_st_adata_t a;
        res_st_vdata_t vk;
        res_st_vdata_t vj;
        rob_addr_t qk;
        rob_addr_t qj;
        res_st_op_t op;
        logic busy;
    } res_st_cell_t;

    //
    //  functions
    //

    function instr_t get_encoding_r_instr(funct3_t funct3, reg_addr_t rd, reg_addr_t rs1, reg_addr_t rs2);
        instr_t instr;
        funct7_t funct7;

        case(funct3)
            FUNCT3_ADD:    funct7 = FUNCT7_ADD;
            FUNCT3_SUB:    funct7 = FUNCT7_SUB;
            FUNCT3_SLL:    funct7 = FUNCT7_SLL; 
            FUNCT3_SLT:    funct7 = FUNCT7_SLT;
            FUNCT3_SLTU:   funct7 = FUNCT7_SLTU;
            FUNCT3_XOR:    funct7 = FUNCT7_XOR;
            FUNCT3_SRL:    funct7 = FUNCT7_SRL;
            FUNCT3_SRA:    funct7 = FUNCT7_SRA;
            FUNCT3_OR:     funct7 = FUNCT7_OR ;
            FUNCT3_AND:    funct7 = FUNCT7_AND;
        endcase
        
        instr = {funct7, rs2, rs1, funct3, rd, R_OPCODE};
        return instr;
    endfunction

    function instr_t get_encoding_i_instr(funct3_t funct3, reg_addr_t rd, reg_addr_t rs1, imm12_t imm12);
        instr_t instr;
        instr = {imm12, rs1, funct3, rd, I_OPCODE};
        return instr;
    endfunction

    function instr_t get_encoding_load_instr(funct3_t funct3, reg_addr_t rd, reg_addr_t rs1, imm12_t imm12);
        instr_t instr;
        instr = {imm12, rs1, funct3, rd, LOAD_OPCODE};
        return instr;
    endfunction

    function instr_t get_encoding_s_instr(funct3_t funct3, reg_addr_t rs1, reg_addr_t rs2, imm12_t imm12);
        instr_t instr;
        instr = {imm12[11:5], rs1, rs1, funct3, imm12[4:0], S_OPCODE};
        return instr;
    endfunction

    function instr_t get_encoding_b_instr(funct3_t funct3, reg_addr_t rs1, reg_addr_t rs2, imm13_t imm13);
        instr_t instr;
        instr = {imm13[12], imm13[10:5], rs2, rs1, funct3, imm13[4:1], imm13[11], B_OPCODE};
        return instr;
    endfunction

    function instr_t get_encoding_jal_instr(reg_addr_t rd, imm21_t imm21);
        instr_t instr;
        instr = {imm21[20], imm21[10:1], imm21[11], imm21[19:12], rd, JAL_OPCODE};
        return instr;
    endfunction

    function instr_t get_encoding_jalr_instr(reg_addr_t rd, reg_addr_t rs1, imm12_t imm12);
        instr_t instr;
        instr = {imm12, rs1, FUNCT3_JALR, rd, JALR_OPCODE};
        return instr;
    endfunction

    function instr_t get_encoding_lui_instr(reg_addr_t rd, imm32_t imm32);
        instr_t instr;
        instr = {imm32[31:12], rd, LUI_OPCODE};
        return instr;
    endfunction

    function instr_t get_encoding_auipc_instr(reg_addr_t rd, imm32_t imm32);
        instr_t instr;
        instr = {imm32[31:12], rd, AUIPC_OPCODE};
        return instr;
    endfunction

    function instr_t get_encoding_syscall_instr(funct3_t funct3);
        instr_t instr;
        imm12_t imm12;
        case(funct3)
            FUNCT3_ECALL:   imm12 = IMM_ECALL;
            FUNCT3_EBREAK:  imm12 = IMM_EBREAK;
        endcase
        instr = {imm12, 5'b0, funct3, 5'b0, SYSCALL_OPCODE};
        return instr;
    endfunction

    function instr_t get_encoding_csr_instr(funct3_t funct3, reg_addr_t rd, imm12_t csr, input logic[4:0] rs1_uimm);
        instr_t instr;
        instr = {csr, rs1_uimm, funct3, rd, CSR_OPCODE};
        return instr;
    endfunction

    function instr_t get_encoding_fence_instr(reg_addr_t rd, reg_addr_t rs1, input logic [3:0] pred, input logic [3:0] succ);
        instr_t instr;
        instr = {4'b0, pred, succ, rs1, FUNCT3_FENCE, rd, FENCE_OPCODE};
        return instr;
    endfunction

    function instr_t get_encoding_fencei_instr();
        instr_t instr;
        instr = {17'b0, FUNCT3_FENCEI, 5'b0, FENCE_OPCODE};
        return instr;
    endfunction

endpackage

`endif
