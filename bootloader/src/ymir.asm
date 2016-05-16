;; Author: Richard Remer

;; Ymir boot environment definitions

%ifndef _YMIR_ASM
%define _YMIR_ASM

%include "bios/boot.asm"
%include "uefi/gpt.asm"

;; stack setup

STACK_SIZE      equ 0x7700  ; 29.75 KiB
STACK_TOP       equ BIOS_BOOT

;; load offset

STAGE1          equ BIOS_BOOT
GPT_HEAD        equ BIOS_FREE
STAGE2          equ BIOS_FREE+512
GPT_PARTS       equ STAGE2+(512+0x80)

;; runtime boot description

struc BootRecord
    .reserved1:     resd 1
    .reserved2:     resb 1
    .boot_drive:    resb 1
    .mbr:           resb MBRPartitionEntry.size * 4
    .sig:           resw 1
    .size:
endstruc

%endif
