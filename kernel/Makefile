all: build/kernel

build/kernel: build/kernel.bin build/entry.bin
	ld -Tlink.ld -obuild/kernel build/entry.bin build/kernel.bin

build/kernel.bin: src/kernel.c
	gdc -c -g src/kernel.c -obuild/kernel.bin

build/entry.bin: src/entry.asm
	nasm -felf64 -obuild/entry.bin src/entry.asm

clean:
	rm -fr build/*
