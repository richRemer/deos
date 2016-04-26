;; std.out(zstring:SI)
std.out:
    lodsb                   ; grab char from SI
    or      al, al          ; test character
    jz      .done           ; bail on nul
    mov     ah, 0x0e        ; BIOS print
    mov     bx, 0x0000      ; page 0, attribute
    int     0x10            ; call BIOS
    jmp     std.out         ; continue with next character
    
    .done:
    ret

;; std.outln(zstring:SI)
std.outln:
    call    std.out         ; pass along message
    mov     si, .endln      ; message
    call    std.out         ; print endln
    ret
    .endln:
        db  0xd,0xa,0x0     ; CRLF\0

