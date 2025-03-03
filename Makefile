NPROC := $(shell nproc)
XLEN = 64
OPENSBI_PLATFORM = generic
ARCH = riscv
CROSS_COMPILE = riscv64-linux-gnu-
QEMU = qemu-system-riscv64
MEMORY = 4G
SBI = ./opensbi/build/platform/generic/firmware/fw_jump.bin
KERNEL = ./linux/arch/riscv/boot/Image
ROOTFS=rootfs.img
FLAG = 	-nographic \
	-machine virt \
	-m $(MEMORY) \
	-bios $(SBI) \
	-kernel $(KERNEL) \
	-append "console=ttyS0 root=/dev/vda ro" \
	-drive file=$(ROOTFS),format=raw,if=virtio

run: $(KERNEL) $(SBI) $(ROOTFS)
	@echo "press Ctrl A and then press X to exit qemu"
	@sleep 1
	${QEMU} $(FLAG)

all: $(KERNEL) $(SBI) $(ROOTFS)

$(KERNEL):
	if [ "$(MENU)" = "y" ]; then \
		echo "Configuring Linux with menuconfig..."; \
		make -C linux ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) menuconfig; \
	else \
		echo "Skipping Busybox menuconfig (MENU not set to y)"; \
	fi
	make -C linux ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -j$(NPROC)

linux: $(KERNEL)

$(SBI):
	make -C opensbi PLATFORM=$(OPENSBI_PLATFORM) CROSS_COMPILE=$(CROSS_COMPILE) PLATFORM_RISCV_XLEN=$(XLEN)

opensbi: $(SBI)

$(ROOTFS):
	if [ "$(MENU)" = "y" ]; then \
		echo "Configuring Busybox with menuconfig..."; \
		make -C busybox ARCH=$(ARCH) menuconfig; \
	else \
		echo "Skipping Busybox menuconfig (MENU not set to y)"; \
	fi
	make -C busybox ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -j$(NPROC)
	make -C busybox ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) install
	qemu-img create $(ROOTFS) 4g
	mkfs.ext4 $(ROOTFS)
	mkdir -p rootfs
	sudo mount -o loop $(ROOTFS) rootfs
	sudo mkdir -p rootfs/etc rootfs/dev rootfs/proc rootfs/sys rootfs/etc/init.d rootfs/bin rootfs/sbin rootfs/proc rootfs/usr rootfs/home rootfs/mnt
	sudo cp -a busybox/_install/* rootfs/
	sudo sh -c ' echo "#!/bin/sh" >> rootfs/etc/init.d/rcS'
	sudo sh -c ' echo "mount -t proc none /proc" >> rootfs/etc/init.d/rcS'
	sudo sh -c ' echo "mount -t sysfs none /sys" >> rootfs/etc/init.d/rcS'
	sudo sh -c ' echo "/sbin/mdev -s" >> rootfs/etc/init.d/rcS'
	sudo chmod +x rootfs/etc/init.d/rcS
	sudo umount rootfs

rootfs: $(ROOTFS)

clean_fs:
	rm -rf rootfs
	make -C busybox clean
	rm $(ROOTFS)

clean_linux:
	make -C linux ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean

clean_opensbi:
	make -C opensbi clean
	make -C busybox clean

clean:
	make -C linux ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean
	make -C opensbi clean
	make -C busybox clean
	rm -rf rootfs
	rm $(ROOTFS)

.PHONY: clean clean_fs clean_linux clean_opensbi linux opensbi rootfs
