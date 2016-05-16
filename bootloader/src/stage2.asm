[ORG 0x8000]
[BITS 16]

;; Author: Richard Remer

%include "cpu/cpuid.asm"
%include "bios/boot.asm"
%include "bios/sys.asm"

SECTION .text

;; stage 2 bootloader

stage2.begin:
    mov     si, lmfail      ; set error message for next check
    call    checkLM         ; check for 64-bit support
    jc      .fail           ; bail if support not detected
    mov     si, lmok        ; success message
    call    outln

    mov     si, a20fail     ; set error message for next check
    call    checkA20        ; check if A20 line is enabled
    jc      .fail           ; bail if A20 line not detected
    mov     si, a20ok       ; success message
    call    outln

    mov     si, memfail     ; set error message for next step
    call    mapmem          ; map system memory
    jc      .fail           ; bail if anything goes wrong
    mov     si, memok       ; success message
    call    outln

    call    showmem         ; display the memory map

    ; query video modes
    ; select good mode
    ; setup GDT
    ; enter long mode

    jmp     .halt           ; terminate

    .fail:
    call    outln           ; SI expected to contain error message

    .halt:
    cli                     ; stop any interrupting funny business
    hlt                     ; halt CPU


;; Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; checkLM() -> CF if unsupported
;; Check for Long Mode (64-bit) support
checkLM:
    mov     eax, CPUIDFN_HIEXTFN    ; set CPUID function
    cpuid                           ; load caps into EAX
    cmp     eax, CPUIDFN_EXTCPU     ; check for extended caps
    jb      .unsupported            ; no caps means no LM
    mov     eax, CPUIDFN_EXTCPU     ; set CPUID function
    cpuid                           ; load extended caps into EDX
    test    edx, 1<<CPUID_LM_BIT    ; check LM bit
    jnz     .supported              ; bit set indicates success

    .unsupported:
    stc                             ; set CF to indicate a problem
    jmp     .done                   ; and return
    
    .supported:
    clc                             ; clear CF to indicate success
    
    .done:
    ret


;; checkA20() -> CF if not enabled
;; Check if A20 line is enabled
checkA20:
    push    ds                      ; preserve
    push    di                      ; preserve
    
    cli                             ; disable interrupts during check
    mov     ax, 0xffff              ; can't set ds directly
    mov     ds, ax                  ; copy value from ax
    mov     si, 0x0510              ; magic?
    mov     di, 0x0500              ; magic?

    mov     al, [es:di]             ; preserve value..
    push    ax                      ; ...on stack
    mov     al, [ds:si]             ; preserve value...
    push    ax                      ; ...on stack

    mov     byte [es:di], 0x00
    mov     byte [ds:si], 0xff
    cmp     byte [es:di], 0xff

    pop     ax                      ; pop stack...
    mov     byte [ds:si], al        ; ...to restore
    pop     ax                      ; pop stack...
    mov     byte [es:di], al        ; ...to restore
    
    pop     di                      ; restore top of memory map
    pop     ds                      ; restore data segment
    
    sti                             ; turn interrupts back on before error

    ; let user know result
    jne     .enabled                ; memory did not wrap
    stc                             ; set CF to indicate a problem
    jmp     .done                   ; and return
    
    .enabled:
    clc                             ; clear CF to indicate success
    
    .done:
    ret


;; mapmem() -> CF if anything goes wrong
;; Load BIOS memory map over the stage1 bootloader
mapmem:
    mov     eax, BIOS_SYS_QUERYMEM  ; set BIOS system function
    mov     di, BIOS_BOOT           ; overwrite bootloader
    xor     ebx, ebx                ; 0 for first entry
    mov     [es:di+MemoryDescriptor.acpi], dword 1
    mov     ecx, MemoryDescriptor.size
    mov     edx, SIG_SMAP           ; system map signature/magic-number
    int     BIOS_SYS                ; load an entry

    ; check for errors/problems
    jc      .fail                   ; unsupported function
    mov     edx, SIG_SMAP           ; might have been clobbered
    cmp     eax, edx                ; success should set EAX to sig
    jne     .fail                   ; mismatch is failure to map memory
    test    ebx, ebx                ; number of entries - 1
    je      .fail                   ; single entry; not useful
    jmp     .entry                  ; begin with first entry
    
    .next_entry:
    mov     eax, BIOS_SYS_QUERYMEM  ; set BIOS system function
    mov     [es:di+MemoryDescriptor.acpi], dword 1
    mov     ecx, MemoryDescriptor.size
    int     BIOS_SYS                ; get next entry (tracked in EBX)
    jc      .mapped                 ; CF indicates end of list
    
    .entry:
    jcxz    .skip_entry             ; skip if length is 0

    ; skip entry if ACPI supported and ignore bit set
    cmp     cl, MemoryDescriptor.acpi
    jbe     .noext                  ; no ACPI extension info
    test    byte [es:di+MemoryDescriptor.acpi], 1
    je      .skip_entry             ; ignore bit is set
    
    .noext:
    mov     ecx, [es:di+8]          ; lower 32 bits of region length
    or      ecx, [es:di+12]         ; with upper 32 bits of region length
    jz      .skip_entry             ; skip entries pointing at 0x00
    mov     ecx, [es:di+MemoryDescriptor.type]
    cmp     ecx, 1                  ; 1 - usable memory
    jnz     .skip_entry             ; skip non-usable memory
    add     di, MemoryDescriptor.size
    
    .skip_entry:
    test    ebx, ebx                ; next entry identifier
    jnz     .next_entry             ; continue to 0
    sub     di, MemoryDescriptor.size
    
    .mapped:
    clc                             ; clear CF for success
    add     di, MemoryDescriptor.size
    jmp     .done                   ; return
    
    .fail:
    stc                             ; set CF for failure
    
    .done:
    ret


;; showmem()
;; Display the memory map
showmem:
    mov     si, BIOS_BOOT   ; memory map loaded here
.chunk:
    mov     eax, [si]       ; low dword into EAX
    mov     ebx, [si+4]     ; high dword into EBX
    call    outq            ; print start address of memory chunk
    
    mov     al, '-'         ; range of memory
    call    outch

    mov     eax, [si]       ; low dword into EAX
    mov     ebx, [si+4]     ; high dword into EBX    
    add     eax, [si+MemoryDescriptor.length]
    jnc     .nocarry        ; check if need to add carry
    inc     ebx             ; carry into EBX
.nocarry:
    add     ebx, [si+MemoryDescriptor.length+4]
    call    outq            ; print end address of memory chunk
    
    mov     al, '/'         ; memory type
    call    outch
    
    mov     eax, [si+MemoryDescriptor.type]
    call    outb            ; print page type (1-avail)
    
    mov     al, 0x0d        ; CR
    call    outch
    mov     al, 0x0a        ; LF
    call    outch

    add     si, MemoryDescriptor.size
    cmp     si, di          ; DI points to end of list
    jne     .chunk          ; show next chunk
    ret


;; pagemem() -> CF if anything goes wrong
;; Build page tables for memory map
pagemem:
    ret

;; import utility functions

%include "console.asm"

;; string data

lmok:       db  "64-bit Long Mode support detected",0x00
lmfail:     db  "CPU does not support 64-bit Long Mode",0x00
memok:      db  "BIOS system memory map complete",0x00
memfail:    db  "Failed to map system memory using BIOS",0x00
a20ok:      db  "A20 line is enabled",0x00
a20fail:    db  "A20 line is not enabled",0x00

;; other data

idt_desc:
    .limit:     dw 0x0000
    .reserved:  dw 0x0000
    .base:      dd 0x00000000
    .size:

;; definitions

STAGE2          equ BIOS_FREE+512   ;; stage2 bootloader loaded here
PAGE_PRESENT    equ 1<<0            ;; page present flag
PAGE_WRITABLE   equ 1<<1            ;; page writable flag

