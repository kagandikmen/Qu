/* 
 * Test sequence for branching
 * Created:     2025-07-13
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
    ori x2, x1, 7
    ori x0, x1, 7
    xori x4, x0, 1
    bne x1, x4, dest1
    addi x4, x0, 10
    bne x1, x4, dest2
dest1:
    addi x4, x0, 15
    addi x7, x0, 20
    addi x8, x0, 25
dest2:
    addi x4, x0, 20