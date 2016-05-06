include build/.config

all: disk.img

disk.img: boot.bin
	dd if=/dev/zero of=build/disk.img bs=$(bs) count=$(count)
	cgpt create build/disk.img
	cgpt add \
		-b$(boot_start) -s$(boot_size) -t$(boot_type) -l$(boot_label) \
		build/disk.img
	cgpt add \
		-b$(os_start) -s$(os_size) -t$(os_type) -l$(os_label) \
		build/disk.img
	cgpt boot -i1 build/disk.img -p
	dd if=build/boot.bin of=build/disk.img bs=64 count=7 conv=notrunc

boot.bin: src/boot.asm
	nasm -obuild/boot.bin -Isrc/ src/boot.asm

clean:
	rm -f build/*
