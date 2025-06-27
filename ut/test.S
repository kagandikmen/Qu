/* 
 * Test sequence
 * Created:     2025-06-24
 * Modified:    2025-06-27
 *
 * Copyright (c) 2025 Kagan Dikmen
 * SPDX-License-Identifier: MIT 
 * See LICENSE for details
 */

.section .init

.global _start
_start:
    la sp, __stack_top
    call main
1:  j 1b

.section .text

main:
    add x0, x0, x0
    addi x1, x1, 3
    li x3, 20
    xor x1, x1, x3
    beq x1, x3, label1
    bne x1, x3, label2
label1:
    sub x3, x3, x1
    li x4, 20
    lw x3, 0(x4)
    j label3
label2:
    add x3, x3, x1
    li x4, 16
    lw x3, 8(x4)
    j label3
label3:
    addi x3, x0, 146
    li x4, -1
    xor x5, x3, x4
1:  j 1b