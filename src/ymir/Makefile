all: disk.img

disk.img: boot.bin
	dd if=/dev/zero of=build/disk.img bs=512 count=262144
	parted build/disk.img mklabel gpt mkpart primary 2048s 100% set 1 boot on
	dd if=build/boot.bin of=build/disk.img bs=128 count=3 conv=notrunc

boot.bin: boot.asm
	nasm -o build/boot.bin boot.asm

clean:
	rm -f build/*
