[ORG 0x7c00]
[BITS 16]

;; Author: Richard Remer

%include "bios/boot.asm"
%include "bios/disk.asm"
%include "uefi/gpt.asm"

SECTION .text

;; stage 1 bootloader

stage1.begin:
    ; ASSUME: segment registers all set to 0x00
    cli                     ; hold off on interrupts while messing with stack
    mov     sp, BIOS_BOOT   ; start stack at bootloader address
    sti                     ; re-enable interrupts

    ; print bootloader identification
    mov     si, ident       ; bootloader identification
    call    outln           ; print message
    
    ; save boot drive and read GPT header
    mov     [drive], dl     ; BIOS leaves drive number here
    mov     ah, BIOS_DISK_READEXT
    mov     si, dap
    mov     [dap+DiskAddressPacket.reserved], byte 0
    mov     [dap+DiskAddressPacket.sectors], word 1 
    mov     [dap+DiskAddressPacket.dst_offset], word GPT_HEAD
    mov     [dap+DiskAddressPacket.dst_segment], word 0
    mov     [dap+DiskAddressPacket.lba_low], dword 1
    mov     [dap+DiskAddressPacket.lba_high], dword 0
    int     BIOS_DISK

    ; calculate size of partition table (assume 512 byte boundary)
    mov     eax, [GPT_HEAD+GPTHeader.num_parts]
    mov     ebx, [GPT_HEAD+GPTHeader.part_size]
    mul     ebx             ; eax,ebx implied
    shr     eax, 9          ; convert eax to sectors in eax
    mov     dx, ax          ; used in DAP sent to disk (2-byte field)

    ; read GPT partition table
    mov     ah, BIOS_DISK_READEXT
    mov     dl, [drive]
    mov     ebx, [GPT_HEAD+GPTHeader.lba_parts]
    mov     ecx, [GPT_HEAD+GPTHeader.lba_parts+4]
    mov     [dap+DiskAddressPacket.sectors], dx
    mov     [dap+DiskAddressPacket.dst_offset], word GPT_PARTS
    mov     [dap+DiskAddressPacket.lba_low], ebx
    mov     [dap+DiskAddressPacket.lba_high], ecx
    int     BIOS_DISK

    ; find stage2 boot partition
    mov     ecx, [GPT_HEAD+GPTHeader.num_parts]
    mov     ebx, [GPT_HEAD+GPTHeader.part_size]
    mov     edx, GPT_PARTS
checkpart:
    jcxz    noboot          ; partitions exhausted

    push    ecx             ; save counter before it gets trashed
    mov     edi, edx        ; partition GUID
    mov     esi, stage2guid ; Ymir stage2 GUID
    mov     ecx, 4          ; 4 dwords makes 16 byte GUID
    repe    cmpsd           ; compare the two
    pop     ecx             ; restore counter

    jz      stage2_load     ; found stage2

    dec     ecx             ; decrement counter
    jmp     checkpart       ; continue with next partition
    
stage2_load:
    ; find partition size (assumes high dword of LBAs match)
    mov     ebx, [edx+GPTPartitionEntry.lba_first]
    mov     ecx, [edx+GPTPartitionEntry.lba_first+4]
    mov     eax, [edx+GPTPartitionEntry.lba_last+4]
    cmp     eax, ecx
    jg      .limit
    
    mov     eax, [edx+GPTPartitionEntry.lba_last]
    sub     eax, ebx
    inc     eax
    cmp     eax, 0x7f       ; based on typical BIOS limit
    jg      .limit
    jmp     .load
    
    .limit:
    mov     eax, 0x7f       ; based on typical BIOS limit
    
    .load:
    mov     dl, [drive]
    mov     si, dap
    mov     [dap+DiskAddressPacket.sectors], ax
    mov     [dap+DiskAddressPacket.dst_offset], word STAGE2
    mov     [dap+DiskAddressPacket.dst_segment], word 0
    mov     [dap+DiskAddressPacket.lba_low], ebx
    mov     [dap+DiskAddressPacket.lba_high], ecx
    mov     ah, BIOS_DISK_READEXT
    int     BIOS_DISK

    ; begin stage2
    jmp     STAGE2

noboot:
    mov     si, nobootpart  ; error message
    call    outln           ; print message
    cli                     ; disable interrupts so nothing wonky happens
    hlt                     ; halt machine

%include "ymir/console.asm"

;; string data

ident:      db  "Ymir v0.0.1",0x00
nobootpart: db  "No boot partition",0x00

;; other data

drive:      db  0x00
stage2guid: dq  0x4125993c16903ab3, 0xd1118457e9487dbf
dap:        db  DiskAddressPacket.size
            times DiskAddressPacket.size-1 db 0x00

;; zero-fill to 512 bytes

times 512 - ($ - $$) db 0x00

;; end of stage1

stage1.end:

;; definitions

GPT_HEAD    equ BIOS_FREE       ; GPT header loaded here
GPT_PARTS   equ BIOS_FREE+512   ; GPT partitions loaded here (temporarily)
STAGE2      equ BIOS_FREE+512   ; stage2 bootloader loaded here

; https://github.com/reniowood/64-bit-Multi-core-OS/tree/master/bootloader
