NPROC := $(shell nproc)
ARCH = riscv
CROSS_COMPILE = riscv64-linux-gnu-
QEMU = qemu-system-riscv64
MEMORY = 4G
SBI = ./opensbi/build/platform/generic/firmware/fw_payload.bin
KERNEL = ./linux/arch/riscv/boot/Image
INITRAMFS = ./initramfs.cpio.gz
FLAG = 	-nographic \
	-machine virt \
	-m $(MEMORY) \
	-bios $(SBI) \
	-kernel $(KERNEL) \
	-initrd $(INITRAMFS) \
	-append "console=ttyS0"

run:
	${QEMU} $(FLAG)

all: linux opensbi rootfs

linux:
	make -C linux ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) defconfig
	make -C linux ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -j$(NPROC)

opensbi:
	make -C opensbi platform=generic CROSS_COMPILE=$(CROSS_COMPILE)

busybox:
	make -C busybox defconfig
	make -C busybox ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -j$(NPROC)
	make -C busybox ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) install

rootfs: busybox
	mkdir rootfs; \
	cd rootfs; \
	mkdir -p bin sbin etc dev proc sys tmp; \
	cp -a ../busybox/_install/* .; \
	sudo mknod dev/console c 5 1; \
	sudo mknod dev/null c 1 3; \
	find . | cpio -o -H newc | gzip > ../initramfs.cpio.gz; \
	cd ..

clean:
	make -C linux ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean
	make -C opensbi clean
	make -C busybox clean
	rm -rf rootfs
	rm initramfs.cpio.gz

.PHONY: all linux opensbi busybox clean
