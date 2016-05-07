;; Author: Richard Remer

GPT_TABLE_BLOCKS    equ 32

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
