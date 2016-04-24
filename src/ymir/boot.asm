[ORG 0x7c00]
[BITS 16]

; Author: Richard Remer

SECTION .text

start:
    mov     sp, 0x7c00      ; start stack at bootloader address
    mov     bp, 0x7c00      ; start base pointer at stack pointer

    mov     si, ident       ; message
    call    outln
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

ident:
    db      "Ymir v0.0.1"   ; bootloader identification
    db      0x00            ; nul-terminated
endln:
    db      0xd,0xa         ; CR/LF
    db      0x00            ; nul-terminated

times 512 - ($ - $$) db 0x00; fill to 512 bytes with 0
end:

; https://github.com/reniowood/64-bit-Multi-core-OS/tree/master/bootloader
