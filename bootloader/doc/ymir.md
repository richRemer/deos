Ymir Bootloader
===============
The `ymir` bootloader aims to be a minimal x86-64 (AMD64/EM64T) bootloader.
Current development target is the [QEMU](http://wiki.qemu.org/Main_Page)
x86_64 emulator.

BIOS Requirements
-----------------
The `ymir` bootloader expects the following to hold true for the initial boot
environment.

 * support for the `cpuid` instruction
 * all i8086 registers (`CS`,`DS`,`SS`,`ES`) set to 0x0 for flat addressing
 * A20 line enabled

Installing Bootloader
---------------------
The `ymir` bootloader, like most bootloader has a small first stage bootloader
that fits in an MBR sector, and a second stage bootloader stored elsewhere,
which is loaded by the first stage bootloader.
