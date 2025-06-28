/* 
 * Test sequence (with only R-type instructions)
 * Created:     2025-06-28
 * Modified:    
 *
 * Copyright (c) 2025 Kagan Dikmen
 * SPDX-License-Identifier: MIT 
 * See LICENSE for details
 */

.section .init

.global _start
_start:
    add x0, x0, x0
    xor x1, x1, x3
    or x2, x0, x1
    sub x3, x2, x4
    sll x4, x4, x3
    slt x3, x7, x6
    sltu x3, x7, x6
    srl x3, x7, x6
    sra x3, x7, x6
    and x3, x7, x6