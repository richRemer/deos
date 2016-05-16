;; Author: Richard Remer

;; GPT disk definitions

%ifndef _GPT_ASM
%define _GPT_ASM

GPT_TABLE_BLOCKS    equ 32
MBR_START           equ 0x1be

struc GPTHeader
    .sig:           resq 1
    .rev:           resd 1
    .header_size:   resd 1
    .crc32:         resd 1
    .reserved:      resd 1
    .lba_head1:     resq 1
    .lba_head2:     resq 1
    .lba_first:     resq 1
    .lba_last:      resq 1
    .guid:          resb 16
    .lba_parts:     resq 1
    .num_parts:     resd 1
    .part_size:     resd 1
    .crc32_parts:   resd 1
    .padding:
endstruc

struc GPTPartitionEntry
    .type_guid:     resb 16
    .guid:          resb 16
    .lba_first:     resq 1
    .lba_last:      resq 1
    .flags:         resq 1
    .utf16name:     resw 36
    .size:
endstruc

struc MBRPartitionEntry
    .reserved:      resb 16
    .size:
endstruc

%endif
