include build/.config

all: disk.img

disk.img: boot.bin
	dd if=/dev/zero of=build/disk.img bs=$(bs) count=$(count)
	yes | parted build/disk.img mklabel gpt
	cgpt add \
		-b$(boot_start) -s$(boot_size) -t$(boot_type) -l$(boot_label) \
		build/disk.img
	cgpt add \
		-b$(os_start) -s$(os_size) -t$(os_type) -l$(os_label) \
		build/disk.img
	parted build/disk.img set 1 boot on
	dd if=build/boot.bin of=build/disk.img bs=128 count=3 conv=notrunc

boot.bin: src/boot.asm
	nasm -obuild/boot.bin -Isrc/ src/boot.asm

clean:
	rm -f build/*
