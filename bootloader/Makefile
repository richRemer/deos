include build/.config

all: disk.img

disk.img: boot.bin stage2.bin
	dd if=/dev/zero of=build/disk.img bs=$(bs) count=$(count)
	cgpt create build/disk.img
	cgpt add -b$(boot_start) -s$(boot_size) -t$(boot_type) -l$(boot_label) build/disk.img
	cgpt add -b$(os_start) -s$(os_size) -t$(os_type) -l$(os_label) build/disk.img
	cgpt boot -i1 build/disk.img -p
	dd if=build/boot.bin of=build/disk.img bs=1 count=445 conv=notrunc
	dd if=build/stage2.bin of=build/disk.img bs=512 seek=$(os_start) conv=notrunc

boot.bin: src/boot.asm
	nasm -obuild/boot.bin -Isrc/ src/boot.asm

stage2.bin: src/stage2.asm
	nasm -obuild/stage2.bin -Isrc/ src/stage2.asm

clean:
	rm -f build/*
