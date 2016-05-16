;; Author: Richard Remer

;; constants describing system BIOS services (INT 15h)

%ifndef _SYS_ASM
%define _SYS_ASM

BIOS_SYS            equ 0x15
BIOS_SYS_QUERYMEM   equ 0xe820

;; for memory map requests ('SMAP' string)
SIG_SMAP        equ 0x0534D4150

;; data structures used by services

struc MemoryDescriptor
    .address:   resq 1
    .length:    resq 1
    .type:      resd 1
    .acpi:      resd 1       ; ACPI 3 extensions
    .size:
endstruc

%endif
