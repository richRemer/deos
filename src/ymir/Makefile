all: boot.bin

boot.bin: boot.asm
	nasm -o build/boot.bin boot.asm

disk.img: boot.bin
	dd if=/dev/zero of=build/disk.img bs=512 count=262144
	parted build/disk.img mklabel gpt mkpart primary 2048s 100% set 1 boot on
	dd if=build/boot.bin of=build/disk.img bs=256 count=1 conv=notrunc

clean:
	rm -f build/*
