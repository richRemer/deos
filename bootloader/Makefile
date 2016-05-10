include build/.config

all: build/boot.bin build/stage2.bin

build/boot.bin: src/boot.asm
	nasm -obuild/boot.bin -Isrc/ src/boot.asm

build/stage2.bin: src/stage2.asm
	nasm -obuild/stage2.bin -Isrc/ src/stage2.asm

clean:
	rm -f build/*
