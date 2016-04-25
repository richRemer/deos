[ORG 0x7c00]
[BITS 16]

; Author: Richard Remer

SECTION .text

start:
    mov     sp, 0x7c00      ; start stack at bootloader address
    mov     bp, 0x7c00      ; start base pointer at stack pointer

    ; print bootloader identification
    mov     si, ident       ; bootloader identification
    call    outln           ; print message
    
    ; check for 64-bit support
    mov     si, err_no64    ; message in case of error
    mov     eax, 0x80000000 ; extended function support function
    cpuid                   ; load caps into EAX
    cmp     eax, 0x80000001 ; extended processor info function
    jb      .error          ; no extended proc. info means no 64-bit support
    
    mov     eax, 0x80000001 ; extended processor info function
    cpuid                   ; load processor info
    test    edx, 1<<29      ; check LM bit
    jz      .error          ; 64-bit unsupported

    mov     si, cap64       ; indicate 64-bit support
    call    outln           ; print message

    jmp     .halt           ; terminate

    .error:
    call    outln           ; message expected in SI
    
    .halt:
    cli
    hlt

; out(zstring:SI)
out:
    lodsb                   ; grab char from SI
    or      al, al          ; test character
    jz      .done           ; bail on nul
    mov     ah, 0x0e        ; BIOS print
    mov     bx, 0x0000      ; page 0, attribute
    int     0x10            ; call BIOS
    jmp     out             ; continue with next character
    
    .done:
    ret

; outln(zstring:SI)
outln:
    call    out             ; pass along message
    mov     si, endln       ; message
    call    out             ; print endln
    ret

ident:      db  "Ymir v0.0.1",0x00
cap64:      db  "64-bit support detected",0x00
err_no64:   db  "64-bit support not detected",0x00
endln:      db  0xd,0xa,0x00

times 512 - ($ - $$) db 0x00; fill to 512 bytes with 0
end:

; https://github.com/reniowood/64-bit-Multi-core-OS/tree/master/bootloader
