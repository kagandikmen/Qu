/* 
 * Test sequence for auipc instruction
 * Created:     2025-07-15
 * Modified:    
 *
 * Copyright (c) 2025 Kagan Dikmen
 * SPDX-License-Identifier: MIT 
 * See LICENSE for details
 */

.section .init

.global _start
_start:
    addi x1, x0, 10
    xori x2, x0, 3
    add x3, x1, x2
    add x4, x1, x3
    auipc x3, 0x40000
    j 0
