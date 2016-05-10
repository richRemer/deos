include build/.config

all: src/boot.bin src/stage2.bin

src/boot.bin: src/boot.asm
	nasm -obuild/boot.bin -Isrc/ src/boot.asm

src/stage2.bin: src/stage2.asm
	nasm -obuild/stage2.bin -Isrc/ src/stage2.asm

clean:
	rm -f build/*
