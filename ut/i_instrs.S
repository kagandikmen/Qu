/* 
 * Test sequence (with only I-type instructions)
 * Created:     2025-07-12
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