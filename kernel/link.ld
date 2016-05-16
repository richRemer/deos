OUTPUT_FORMAT(elf64-x86-64)
ENTRY (kentry)

SECTIONS {
    . = 0x00100000;             /* 1 MiB */
    
    .text :{
        code = .; _code = .; __code = .;
        *(.text)
        *(.rodata)
    }
    
    .rodata ALIGN (0x1000) :{   /* 4 KiB */
        *(.rodata)
    }
    
    .data ALIGN (0x1000) :{     /* 4 KiB */
        data = .; _data = .; __data = .;
        *(.data)
        start_ctors = .; *(.ctors)  end_ctors = .;
        start_dtors = .; *(.dtors)  end_dtors = .;
    }
    
    .bss :{
        sbss = .;
        bss = .; _bss = .; __bss = .;
        *(COMMON)
        *(.bss)
        ebss = .;
    }
    
    end = .; _end = .; __end = .;
}
