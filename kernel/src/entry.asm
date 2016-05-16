[BITS 16]

global kentry

extern kmain
extern start_ctors, end_ctors, start_dtors, end_dtors

STACK_SIZE  equ 0x10000         ; 64KiB
MOD_ALIGN   equ 1<<0
MEM_INFO    equ 1<<1
MBOOT_FLAGS equ MOD_ALIGN | MEM_INFO
MAGIC       equ 0x1BADB002      ; multi-boot magic number
CHECKSUM    equ -(MAGIC + MBOOT_FLAGS)

section .text
align 4

multi_boot_header:
    dd      MAGIC
    dd      MBOOT_FLAGS
    dd      CHECKSUM

;; run C++ constructors
;; for now I'm treating this as dlang magic; I don't know how or when it gets
;; called

static_ctors_loop:
    mov     ebx, start_ctors    ; point EBX at ctors
    jmp     .check_end          ; check for end before continuing
    
    .next_ctor:
    call    [ebx]               ; call the ctor
    add     ebx, 4              ; move to next ctor offset
    
    .check_end:
    cmp     ebx, end_ctors      ; compare to end offset
    jb      .next_ctor          ; continue ctor'ing

;; entry point

kentry:
    mov     esp, stack+STACK_SIZE
    push    eax
    push    ebx
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
