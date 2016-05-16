;; fnv1a_hash(ptr:DS:SI, len:ECX) => EBX
;; Perform 32-bit FNV-1a hash.
;; SI scanned, EAX trashed, clears DF
;; http://www.isthe.com/chongo/tech/comp/fnv/#FNV-1a
fnv1a_hash:
    mov     ebx, 2166136261     ; hash magic!
    jcxz    .done               ; done if nothing to hash
    cld                         ; scan forward
    
    .hash:
    lodsb                       ; into AL
    xor     ebx, al             ; mix it into the hash
    mul     ebx, 16777619       ; twiddle some bits (magic!)
    dec     ecx                 ; count down...
    jcxz    .done               ; ...to zero
    jmp     .hash               ; continue hashing
    
    .done:
    ret
