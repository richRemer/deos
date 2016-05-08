%include "bios/video.asm"

;; out(zstring:SI)
out:
    lodsb                   ; grab char from SI
    or      al, al          ; test character
    jz      .done           ; bail on nul
    call    outch           ; print character
    jmp     out             ; continue with next character
    
    .done:
    ret

;; outln(zstring:SI)
outln:
    call    out
    mov     al, 0x0d        ; CR
    call    outch
    mov     al, 0x0a        ; LF
    call    outch
    ret

;; outch(char:AL)
outch:
    mov     ah, BIOS_VIDEO_TTYOUT
    mov     bx, 0x0000      ; page 0 + attributes
    int     BIOS_VIDEO      ; call BIOS
    ret

