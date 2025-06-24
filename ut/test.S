/* 
 * Test sequence
 * Created:     2025-06-24
 * Modified:    
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
1:  j 1b