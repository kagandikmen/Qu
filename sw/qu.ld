/* 
 * Generic linker script for The Qu Processor
 * Created:     2025-06-24
 * Modified:    
 *
 * Copyright (c) 2025 Kagan Dikmen
 * SPDX-License-Identifier: MIT 
 * See LICENSE for details
 */

ENTRY(_start)

MEMORY
{
    pmem (rx)   : ORIGIN = 0x00000000, LENGTH = 4K
    dmem (rw)   : ORIGIN = 0x00001000, LENGTH = 4K
}

SECTIONS
{
    .text : {
        *(.init)

        __text_begin = .;
        *(.text*)
        __text_end = .;
    } > pmem

    .rodata : {
        __rodata_begin = .;
        *(.rodata*)
        __rodata_end = .;
    } > dmem

    .data : {
        __data_begin = .;
        *(.data*)
        *(.sdata*)
        *(.eh_frame*)
        __data_end = .;
    } > dmem

    .bss : {
        __bss_begin = .;
        *(.bss*)
        *(.sbss*)
        *(COMMON)
        __bss_end = .;
    } > dmem

    __stack_top = 0xFFC;

    /DISCARD/ : {
        *(.comment*)
    }
}