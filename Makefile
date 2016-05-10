include build/.config

all: build/os.img

build/os.img: BOOTLOADER
	dd if=/dev/zero of=build/os.img bs=$(bs) count=$(count)
	cgpt create build/os.img
	cgpt add -b$(boot_start) -s$(boot_size) -t$(boot_type) -l$(boot_label) build/os.img
	cgpt add -b$(os_start) -s$(os_size) -t$(os_type) -l$(os_label) build/os.img
	cgpt boot -i1 build/os.img -p
	dd if=bootloader/build/boot.bin of=build/os.img bs=1 count=445 conv=notrunc
	dd if=bootloader/build/stage2.bin of=build/os.img bs=512 seek=$(boot_start) conv=notrunc

BOOTLOADER:
	$(MAKE) -C bootloader

clean:
	$(MAKE) -C bootloader clean
	rm -f build/*
