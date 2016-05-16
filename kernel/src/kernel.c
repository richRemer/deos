void kmain() {
    const unsigned long VIDMEM = 0xffff8000000b8000;
    const unsigned int COLS = 80;
    const unsigned int ROWS = 25;
    int x = 0;
    int y = 0;
    
    volatile unsigned char* vidmem = (unsigned char*)VIDMEM;
    
    // clear video memory
    for (int i = 0; i < COLS * ROWS * 2; i++) {
        vidmem[i] = 0;
    }
    
    vidmem[0] = 'K' & 0xff;
    vidmem[1] = 0x07;
    
    // loop forever
    for (;;) ;
}
