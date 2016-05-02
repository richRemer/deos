;; std.out(zstring:SI)
std.out:
    lodsb                   ; grab char from SI
    or      al, al          ; test character
    jz      .done           ; bail on nul
    call    std.outch       ; print character
    jmp     std.out         ; continue with next character
    
    .done:
    ret

;; std.outch(char:AL)
std.outch:
    mov     ah, 0x0e        ; BIOS print
    mov     bx, 0x0000      ; page 0 + attributes
    int     0x10            ; call BIOS
    ret

