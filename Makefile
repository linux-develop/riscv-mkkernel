NPROC := $(shell nproc)
XLEN = 64
OPENSBI_PLATFORM = generic
ARCH = riscv
CROSS_COMPILE = riscv64-linux-gnu-
GDB = gdb-multiarch
CPU = 1
QEMU = qemu/build/qemu-system-riscv64
MEMORY = 4G
SBI = ./opensbi/build/platform/generic/firmware/fw_jump
SBI_BIN = $(SBI).bin
SBI_ELF = $(SBI).elf
KERNEL = ./linux/arch/riscv/boot/Image
VMLINUX = ./linux/vmlinux
ROOTFS=rootfs.img
FLAG = 	-nographic \
	-machine virt \
	-m $(MEMORY) \
	-smp $(CPU) \
	-bios $(SBI_BIN) \
	-kernel $(KERNEL) \
	-append "console=ttyS0 root=/dev/vda ro" \
	-drive file=$(ROOTFS),format=raw,if=virtio

run: $(KERNEL) $(SBI_BIN) $(ROOTFS)
	@echo "press Ctrl A and then press X to exit qemu"
	@sleep 1
	if [ "$(LOG)" = "y" ]; then \
		${QEMU} $(FLAG) -D qemu.log -d cpu,mmu,page; \
	else \
		${QEMU} $(FLAG); \
	fi

debug: $(KERNEL) $(SBI_BIN) $(ROOTFS)
	$(QEMU) $(FLAG) -s -S

gdb: $(VMLINUX)
	$(GDB) $(VMLINUX)

debug_qemu: $(QEMU) $(KERNEL) $(SBI_BIN) $(ROOTFS)
	$(GDB) -tui -args $(QEMU) $(FLAG)

all: $(KERNEL) $(SBI_BIN) $(ROOTFS) $(QEMU)

$(KERNEL):
	if [ "$(MENU)" = "y" ]; then \
		echo "Configuring Linux with menuconfig..."; \
		make -C linux ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) menuconfig; \
	else \
		echo "Skipping Linux menuconfig (MENU not set to y)"; \
	fi
	make -C linux ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -j$(NPROC)

linux: $(KERNEL)

$(SBI_BIN):
	if [ "$(DEBUG)" = "y" ]; then \
		echo "Compile opensbi with debug mode..."; \
		make -C opensbi PLATFORM=$(OPENSBI_PLATFORM) CROSS_COMPILE=$(CROSS_COMPILE) PLATFORM_RISCV_XLEN=$(XLEN) DEBUG=1; \
	else \
		make -C opensbi PLATFORM=$(OPENSBI_PLATFORM) CROSS_COMPILE=$(CROSS_COMPILE) PLATFORM_RISCV_XLEN=$(XLEN); \
	fi

opensbi: $(SBI_BIN)

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

$(QEMU):
	make -C qemu/build -j$(NPROC)

qemu: $(QEMU)

clean_rootfs:
	rm -rf rootfs
	make -C busybox clean
	rm $(ROOTFS)

clean_linux:
	make -C linux ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean

clean_opensbi:
	make -C opensbi clean

clean_qemu:
	make -C qemu/build clean

clean:
	make -C linux ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean
	make -C opensbi clean
	make -C busybox clean
	make -C qemu/build clean
	rm -rf rootfs
	rm $(ROOTFS)

distclean:
	make -C linux disclean
	make -C opensbi distclean
	make -C busybox distclean
	make -C qemu/build distclean
	rm -rf rootfs
	rm $(ROOTFS)

.PHONY: clean distclean clean_rootfs clean_linux clean_opensbi clean_qemu linux opensbi rootfs debug gdb debug_qemu
