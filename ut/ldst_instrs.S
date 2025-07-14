/* 
 * Test sequence for load-store instructions
 * Created:     2025-07-14
 * Modified:    
 *
 * Copyright (c) 2025 Kagan Dikmen
 * SPDX-License-Identifier: MIT 
 * See LICENSE for details
 */

.section .init

.global _start
_start:
    addi x1, x0, 8
    addi x2, x0, 4
    sw x1, 0(x2)
    addi x1, x1, 4
    sw x1, 4(x2)
    add x3, x2, x2
    lw x3, 0(x2)
    lw x4, 4(x2)