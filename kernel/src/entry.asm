[BITS 16]

global kentry
extern kmain

STACK_SIZE  equ 0x10000         ; 64KiB

;; entry point

kentry:
    mov     esp, stack+STACK_SIZE
    call    kmain

;; run D constructors
;; for now I'm treating this as dlang magic; I don't know how or when it gets
;; called

static_dtors_loop:
    mov     ebx, start_dtors    ; point EBX at dtors
    jmp     .check_end          ; check for end before continuing
    
    .next_dtor:
    call    [ebx]               ; call the dtor
    add     ebx, 4              ; move to next dtor offset
    
    .check_end:
    cmp     ebx, end_dtors      ; compare to end offset
    jb      .next_dtor          ; continue dtor'ing

cpuhalt:
    cli
    hlt
    jmp cpuhalt

section .bss
align 32

stack:
    resb    STACK_SIZE
