set architecture i8086
set disassembly-flavor intel
target remote localhost:1234
br *0x7c00
br *0x8000
