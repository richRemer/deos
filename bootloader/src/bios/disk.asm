;; Author: Richard Remer

;; constants describing disk BIOS services

BIOS_DISK           equ 0x13
BIOS_DISK_RESET     equ 0x00
BIOS_DISK_READEXT   equ 0x42

;; data structures used by services

struc DiskAddressPacket
    .dap_size:      resb 1
    .reserved:      resb 1
    .sectors:       resw 1
    .dst_offset:    resw 1
    .dst_segment:   resw 1
    .lba_low:       resd 1
    .lba_high:      resd 1
    .size:
endstruc
