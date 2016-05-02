[ORG 0x7c00]
[BITS 16]

; Author: Richard Remer

%include "cpuid.asm"
%include "bios/boot.asm"

SECTION .text

;; bootloader

startboot:
    ;; ASSUME: segment registers all set to 0x00
    cli                     ; hold off on interrupts while messing with stack
    mov     sp, BOOT        ; start stack at bootloader address
    sti                     ; re-enable interrupts

    ; print bootloader identification
    mov     si, ident       ; bootloader identification
    call    std.out
    call    ok
    
    ; let user know loader is checking for 64-bit support
    mov     si, cap64       ; message
    call    std.out

    ; check for 64-bit support
    mov     eax, CPUIDFN_HIEXTFN
    cpuid                   ; load caps into EAX
    cmp     eax, CPUIDFN_EXTCPU
    jb      .error          ; no extended proc. info means no 64-bit support
    mov     eax, CPUIDFN_EXTCPU
    cpuid                   ; load processor info
    test    edx, 1<<CPUID_LM_BIT

    ; let user know the result
    jz      .error          ; 64-bit unsupported
    call    ok

    ; query video modes
    ; select good mode
    
    ; let user know loader is checking BIOS memory map
    mov     si, capmem      ; message
    call    std.out

    ; map system memory
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
    ; let user know memory was mapped
    call    ok
    
    ; let user know loader is checking A20 line
    mov     si, a20         ; A20 line message
    call    std.out         ; print message
    
    ; check A20 line
    push    ds              ; preserve
    push    di              ; preserve
    
    cli                     ; disable interrupts during check
    mov     ax, 0xffff      ; can't set ds directly
    mov     ds, ax          ; copy value from ax
    mov     si, 0x0510      ; magic?
    mov     di, 0x0500      ; magic?

    mov     al, [es:di]     ; preserve value..
    push    ax              ; ...on stack
    mov     al, [ds:si]     ; preserve value...
    push    ax              ; ...on stack

    mov     byte [es:di], 0x00
    mov     byte [ds:si], 0xff
    cmp     byte [es:di], 0xff

    pop     ax              ; pop stack...
    mov     byte [ds:si], al; ...to restore
    pop     ax              ; pop stack...
    mov     byte [es:di], al; ...to restore
    
    pop     di              ; restore top of memory map
    pop     ds              ; restore data segment
    
    sti                     ; turn interrupts back on before error

    ; let user know result
    je      .error          ; memory wrapped
    call    ok
    
    ; setup GDT
    ; enter long mode

    jmp     .halt           ; terminate

    .error:
    mov     al, '-'         ; something went wrong with last module
    call    std.outch
    
    .halt:
    cli
    hlt

ok:
    mov     al, '+'
    call    std.outch
    ret

%include "std.asm"

;; string data

ident:      db  "Ymir v0.0.1",0x00
cap64:      db  "x86-64",0x00
capmem:     db  "mmap",0x00
a20:        db  "A20",0x00

;; other data

drive:      db  0x00

;; zero-fill to 512 bytes

times 512 - ($ - $$) db 0x00

;; end of bootloader

free:                       ; guaranteed free space 0x7e00 - 0x7ffff

;; definitions

SIG_SMAP    equ 0x0534D4150 ; for memory map requests ('SMAP')
STAGE2      equ 0x8000      ; stage 2 bootloader loaded here

struc MemoryDescriptor
    .address:   resq 1
    .length:    resq 1
    .type:      resd 1
    .acpi:      resd 1       ; ACPI 3 extensions
    .size:
endstruc

; https://github.com/reniowood/64-bit-Multi-core-OS/tree/master/bootloader
