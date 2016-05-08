;; Author: Richard Remer

;; constants describing the initial boot environment provided by the BIOS

BIOS_IVT            equ 0x000000    ;; Interrupt Vector Table
BIOS_BDA            equ 0x000400    ;; BIOS data area
BIOS_FREE_EXTRA     equ 0x000500    ;; guaranteed free space (29.75 KiB)
BIOS_BOOT           equ 0x007c00    ;; bootloader loaded here
BIOS_FREE           equ 0x007e00    ;; guaranteed free space (480.5 KiB)
BIOS_FREE_MAYBE     equ 0x080000    ;; maybe free space + EBDA (128 KiB)
BIOS_RESERVED       equ 0x0a0000    ;; video RAM, ROM, etc.

