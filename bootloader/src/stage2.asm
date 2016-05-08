[ORG 0x8000]
[BITS 16]

;; Author: Richard Remer

%include "cpu/cpuid.asm"
%include "bios/boot.asm"
%include "bios/sys.asm"

SECTION .text

;; stage 2 bootloader

stage2.begin:
    ; print message for 64-bit support
    mov     si, x64         ; message address
    call    out

    ; check for 64-bit support
    mov     eax, CPUIDFN_HIEXTFN
    cpuid                   ; load caps into EAX
    cmp     eax, CPUIDFN_EXTCPU
    jb      fail            ; no extended proc. info means no 64-bit support
    mov     eax, CPUIDFN_EXTCPU
    cpuid                   ; load processor info
    test    edx, 1<<CPUID_LM_BIT

    ; let user know the result
    jz      fail            ; 64-bit unsupported
    call    ok

    ; query video modes
    ; select good mode
    
    ; print message for memory map
    mov     si, mmap        ; message address
    call    out

    ; map system memory
    mov     eax, BIOS_SYS_QUERYMEM
    mov     di, BIOS_BOOT   ; target buffer
    xor     ebx, ebx        ; 0 for first entry
    mov     [es:di+MemoryDescriptor.acpi], dword 1
    mov     ecx, MemoryDescriptor.size
    mov     edx, SIG_SMAP   ; System Map signature
    int     BIOS_SYS
    jc      fail            ; unsupported function
    mov     edx, SIG_SMAP   ; might have been clobbered
    cmp     eax, edx        ; success should set EAX to sig
    jne     fail            ; failed to map memory
    test    ebx, ebx        ; number of entries - 1
    je      fail            ; single entry; not useful
    jmp     .entry          ; begin with first entry
    
    .next_entry:
    mov     eax, BIOS_SYS_QUERYMEM
    mov     [es:di+MemoryDescriptor.acpi], dword 1
    mov     ecx, MemoryDescriptor.size
    int     BIOS_SYS
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
    mov     si, a20         ; message address
    call    out             ; print message
    
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
    je      fail            ; memory wrapped
    call    ok
    
    ; setup GDT
    ; enter long mode

    jmp     halt            ; terminate

ok:
    mov     si, okmsg
    call    outln
    ret

fail:
    mov     si, failmsg
    call    outln
    
halt:
    cli
    hlt

%include "ymir/console.asm"

;; string data

okmsg:      db  " - ok",0x00
failmsg:    db  " - failed",0x00
x64:        db  "x86-64 support",0x00
mmap:       db  "BIOS memory map",0x00
a20:        db  "A20 line",0x00

;; definitions

STAGE2      equ BIOS_FREE+512   ;; stage2 bootloader loaded here
