;; Author: Richard Remer

;; constants describing the initial boot environment provided by the BIOS

;; memory offset of bootloader code
BOOT        equ 0x7c00

;; guaranteed free space
FREE_START  equ 0x7e00
FREE_END    equ 0x80000
