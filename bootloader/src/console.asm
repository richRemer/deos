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

;; outb(int:AL)
outb:
    lea     ebx, [hexits]   ; lookup table for xlat below
    mov     ah, al          ; dupe byte in AH
    shr     al, 4           ; high nibble in AL
    and     ah, 0x0f        ; low nibble in AH

    xlat                    ; lookup hexit for AL and replace it
    push    ax              ; save for later
    push    ebx             ; save for later
    call    outch           ; print first hexit
    pop     ebx             ; restore
    pop     ax              ; restore
    
    xchg    ah, al          ; swap result and other nibble
    xlat                    ; lookup hexit for the other nibble
    call    outch           ; print second hexit
    
    ret

;; outw(int:AX)
outw:
    push    ax              ; save before trashing
    mov     al, ah          ; start with high byte
    call    outb            ; print byte
    pop     ax              ; restore with AL containing next byte
    call    outb            ; print byte
    ret

;; outd(int:EAX)
outd:
    push    eax             ; save before trashing
    shr     eax, 16         ; move high word into low word
    call    outw            ; print word
    pop     eax             ; restore with AX containing next word
    call    outw            ; print word
    ret

;; outq(int:EAX, int:EBX)
outq:
    push    eax             ; save before trashing
    mov     eax, ebx        ; move high dword into EAX
    call    outd            ; print high dword
    pop     eax             ; restore EAX containing next dword
    call    outd            ; print low dword
    ret

hexits:     db "0123456789abcdef", 0x00
