[ORG 0x7c00]
[BITS 16]

; Author: Richard Remer

SECTION .text

;; bootloader

startboot:
    mov     sp, 0x7c00      ; start stack at bootloader address
    mov     bp, 0x7c00      ; start base pointer at stack pointer

    ; print bootloader identification
    mov     si, ident       ; bootloader identification
    call    std.outln       ; print message
    
    ; check for 64-bit support
    mov     si, cap64       ; capability check message
    call    std.out         ; print message
    mov     eax, 0x80000000 ; extended function support function
    cpuid                   ; load caps into EAX
    cmp     eax, 0x80000001 ; extended processor info function
    jb      .error          ; no extended proc. info means no 64-bit support
    mov     eax, 0x80000001 ; extended processor info function
    cpuid                   ; load processor info
    test    edx, 1<<29      ; check LM bit
    jz      .error          ; 64-bit unsupported
    mov     si, okmsg       ; 64-bit ok
    call    std.outln

    ; query video modes
    ; select good mode
    
    ; map system memory
    mov     si, capmem      ; capability memory map message
    call    std.out         ; print message
    mov     eax, 0xe820     ; query system address map function
    mov     di, free        ; target buffer
    xor     ebx, ebx        ; 0 for first entry
    mov     [es:di+MemoryDescriptor.acpi], dword 1
    mov     ecx, MemoryDescriptor.size
    mov     edx, SIG_SMAP   ; System Map signature
    int     0x15            ; fill memory descriptor
    jc      .error          ; unsupported function
    mov     edx, SIG_SMAP   ; might have been clobbered
    cmp     eax, edx        ; success should set EAX to sig
    jne     .error          ; failed to map memory
    test    ebx, ebx        ; number of entries - 1
    je      .error          ; single entry; not useful
    jmp     .entry          ; begin with first entry
    
    .next_entry:
    mov     eax, 0xe820     ; query system address map function
    mov     [es:di+MemoryDescriptor.acpi], dword 1
    mov     ecx, MemoryDescriptor.size
    int     0x15            ; fill memory descriptor
    jc      .mapped         ; carry flag indicates end of list
    
    .entry:
    jcxz    .skip_entry     ; skip if length is 0
    cmp     cl, MemoryDescriptor.acpi
    jbe     .noext          ; no ACPI extension info
    test    byte [es:di+MemoryDescriptor.acpi], 1
    je      .skip_entry     ; ignore bit is set
    
    .noext:
    mov     ecx, [es:di+8]  ; lower 32 bits of region length
    or      ecx, [es:di+12] ; with upper 32 bits of region length
    js      .skip_entry     ; 0 address
    add     di, MemoryDescriptor.size
    
    .skip_entry:
    test    ebx, ebx        ; next entry identifier
    jne     .next_entry     ; done if 0
    
    .mapped:
    mov     si, okmsg       ; memory map ok
    call    std.outln       ; print status
    
    ; enable a20 line
    ; setup GDT
    ; enter long mode

    jmp     .halt           ; terminate

    .error:
    mov     si, errmsg      ; something went wrong with last module
    call    std.outln       ; print error
    
    .halt:
    cli
    hlt

%include "std.asm"

;; string data

ident:      db  "Ymir v0.0.1",0x00
cap64:      db  "x86-64",0x00
capmem:     db  "mmap",0x00
okmsg:      db  ":ok",0x00
errmsg:     db  ":error",0x00

times 512 - ($ - $$) db 0x00; fill to 512 bytes with 0

;; end of bootloader

free:                       ; guaranteed free space 0x7e00 - 0x7ffff

;; definitions

SIG_SMAP    equ 0x0534D4150 ; for memory map requests

struc MemoryDescriptor
    .address:   resq 1
    .length:    resq 1
    .type:      resd 1
    .acpi:      resd 1       ; ACPI 3 extensions
    .size:
endstruc

; https://github.com/reniowood/64-bit-Multi-core-OS/tree/master/bootloader
