NPROC := $(shell nproc)
XLEN = 64
OPENSBI_PLATFORM = generic
ARCH = riscv
CROSS_COMPILE = riscv64-linux-gnu-
GDB = gdb-multiarch
CPU = 1
MEMORY = 4G

QEMU = qemu/build/qemu-system-riscv64
SBI = ./opensbi/build/platform/generic/firmware/fw_jump
SBI_BIN = $(SBI).bin
SBI_ELF = $(SBI).elf
KERNEL = ./linux/arch/riscv/boot/Image
VMLINUX = ./linux/vmlinux
BUSYBOX= rootfs.img
BUILDROOT=buildroot/output/images/rootfs.ext2

FLAG = 	-nographic \
	-machine virt \
	-m $(MEMORY) \
	-smp $(CPU) \
	-bios $(SBI_BIN) \
	-kernel $(KERNEL) \
	-append "console=ttyS0 root=/dev/vda rw" \
        -drive file=$(BUILDROOT),if=virtio
	#-drive file=$(BUSYBOX),format=raw,if=virtio

QEMU_LOG_FLAG = -D qemu.log -d exec,cpu,mmu,page,invalid_mem

OQEMU = qemu-origin/build/qemu-system-riscv64
OSBI = ./opensbi-origin/build/platform/generic/firmware/fw_jump
OSBI_BIN = $(OSBI).bin
OSBI_ELF = $(OSBI).elf
OKERNEL = ./linux-origin/arch/riscv/boot/Image
OVMLINUX = ./linux-origin/vmlinux
OBUSYBOX=rootfs-origin.img
OBUILDROOT=buildroot/output/images/rootfs.ext2
OFLAG = -nographic \
        -machine virt \
        -m $(MEMORY) \
        -smp $(CPU) \
        -bios $(OSBI_BIN) \
        -kernel $(OKERNEL) \
        -append "console=ttyS0 root=/dev/vda rw" \
        -drive file=$(OBUILDROOT),if=virtio
        #-drive file=$(OBUSYBOX),format=raw,if=virtio

run: $(QEMU) $(KERNEL) $(SBI_BIN) $(ROOTFS)
	@echo "press Ctrl A and then press X to exit qemu"
	@sleep 1
	if [ "$(LOG)" = "y" ]; then \
		${QEMU} $(FLAG) $(QEMU_LOG_FLAG); \
	else \
		${QEMU} $(FLAG); \
	fi

orun: $(OQEMU) $(OKERNEL) $(OSBI_BIN) $(OROOTFS)
	@echo "press Ctrl A and then press X to exit qemu"
	@sleep 1
	if [ "$(LOG)" = "y" ]; then \
		${OQEMU} $(OFLAG) $(QEMU_LOG_FLAG); \
	else \
		${OQEMU} $(OFLAG); \
	fi

debug: $(QEMU) $(KERNEL) $(SBI_BIN) $(ROOTFS)
	if [ "$(LOG)" = "y" ]; then \
		$(QEMU) $(FLAG) -s -S $(QEMU_LOG_FLAG); \
	else \
		$(QEMU) $(FLAG) -s -S; \
	fi	

gdb: $(VMLINUX)
	$(GDB) $(VMLINUX)

debug_qemu: $(QEMU) $(KERNEL) $(SBI_BIN) $(ROOTFS)
	if [ "$(LOG)" = "y" ]; then \
		$(GDB) -tui -args $(QEMU) $(FLAG) $(QEMU_LOG_FLAG); \
	else \
		$(GDB) -tui -args $(QEMU) $(FLAG); \
	fi

all: $(KERNEL) $(SBI_BIN) $(BUILDROOT) $(QEMU)
oall: $(OKERNEL) $(OSBI_BIN) $(OBUILDROOT) $(OQEMU)

$(KERNEL):
	if [ "$(MENU)" = "y" ]; then \
		echo "Configuring Linux with menuconfig..."; \
		make -C linux ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) menuconfig; \
	else \
		echo "Skipping Linux menuconfig (MENU not set to y)"; \
	fi
	make -C linux ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -j$(NPROC)

linux: $(KERNEL)

$(OKERNEL):
	if [ "$(MENU)" = "y" ]; then \
		echo "Configuring Linux with menuconfig..."; \
		make -C linux-origin ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) menuconfig; \
	else \
		echo "Skipping Linux menuconfig (MENU not set to y)"; \
	fi
	make -C linux-origin ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -j$(NPROC)

olinux: $(OKERNEL)

$(SBI_BIN):
	if [ "$(DEBUG)" = "y" ]; then \
		echo "Compile opensbi with debug mode..."; \
		make -C opensbi PLATFORM=$(OPENSBI_PLATFORM) CROSS_COMPILE=$(CROSS_COMPILE) PLATFORM_RISCV_XLEN=$(XLEN) DEBUG=1; \
	else \
		make -C opensbi PLATFORM=$(OPENSBI_PLATFORM) CROSS_COMPILE=$(CROSS_COMPILE) PLATFORM_RISCV_XLEN=$(XLEN); \
	fi

opensbi: $(SBI_BIN)

$(OSBI_BIN):
	if [ "$(DEBUG)" = "y" ]; then \
		echo "Compile opensbi with debug mode..."; \
		make -C opensbi-origin PLATFORM=$(OPENSBI_PLATFORM) CROSS_COMPILE=$(CROSS_COMPILE) PLATFORM_RISCV_XLEN=$(XLEN) DEBUG=1; \
	else \
		make -C opensbi-origin PLATFORM=$(OPENSBI_PLATFORM) CROSS_COMPILE=$(CROSS_COMPILE) PLATFORM_RISCV_XLEN=$(XLEN); \
	fi

oopensbi: $(OSBI_BIN)

$(BUSYBOX):
	if [ "$(MENU)" = "y" ]; then \
		echo "Configuring Busybox with menuconfig..."; \
		make -C busybox ARCH=$(ARCH) menuconfig; \
	else \
		echo "Skipping Busybox menuconfig (MENU not set to y)"; \
	fi
	make -C busybox ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) LDFLAGS="-Wl,-z,max-page-size=0x4000" -j$(NPROC)
	make -C busybox ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) LDFLAGS="-Wl,-z,max-page-size=0x4000" install
	qemu-img create $(BUSYBOX) 4g
	mkfs.ext4 $(BUSYBOX)
	mkdir -p rootfs
	sudo mount -o loop $(BUSYBOX) rootfs
	sudo mkdir -p rootfs/etc rootfs/dev rootfs/proc rootfs/sys rootfs/etc/init.d rootfs/bin rootfs/sbin rootfs/proc rootfs/usr rootfs/home rootfs/mnt
	sudo cp -a busybox/_install/* rootfs/
	sudo sh -c ' echo "#!/bin/sh" >> rootfs/etc/init.d/rcS'
	sudo sh -c ' echo "mount -t proc none /proc" >> rootfs/etc/init.d/rcS'
	sudo sh -c ' echo "mount -t sysfs none /sys" >> rootfs/etc/init.d/rcS'
	sudo sh -c ' echo "/sbin/mdev -s" >> rootfs/etc/init.d/rcS'
	sudo chmod +x rootfs/etc/init.d/rcS
	sudo mkdir -p rootfs/test
	sudo cp -a scripts/*.sh rootfs/test/
	sudo chmod +x rootfs/test/*.sh
	sudo sh -c ' echo "/test/01_mem_usage.sh" >> rootfs/etc/init.d/rcS'
	sudo sh -c ' echo "/test/02_stress_test.sh" >> rootfs/etc/init.d/rcS'
	sudo sh -c ' echo "/test/03_io_test.sh" >> rootfs/etc/init.d/rcS'
	sudo sh -c ' echo "/test/04_page_faults.sh" >> rootfs/etc/init.d/rcS'
	sudo umount rootfs

rootfs: $(RBUSYBOX)

$(OBUSYBOX):
	if [ "$(MENU)" = "y" ]; then \
		echo "Configuring Busybox with menuconfig..."; \
		make -C busybox-origin ARCH=$(ARCH) menuconfig; \
	else \
		echo "Skipping Busybox menuconfig (MENU not set to y)"; \
	fi
	make -C busybox-origin ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -j$(NPROC)
	make -C busybox-origin ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) install
	qemu-img create $(OROOTFS) 4g
	mkfs.ext4 $(OROOTFS)
	mkdir -p rootfs-origin
	sudo mount -o loop $(OROOTFS) rootfs-origin
	sudo mkdir -p rootfs-origin/etc rootfs-origin/dev rootfs-origin/proc rootfs-origin/sys rootfs-origin/etc/init.d rootfs-origin/bin rootfs-origin/sbin rootfs-origin/proc rootfs-origin/usr rootfs-origin/home rootfs-origin/mnt
	sudo cp -a busybox-origin/_install/* rootfs-origin/
	sudo sh -c ' echo "#!/bin/sh" >> rootfs-origin/etc/init.d/rcS'
	sudo sh -c ' echo "mount -t proc none /proc" >> rootfs-origin/etc/init.d/rcS'
	sudo sh -c ' echo "mount -t sysfs none /sys" >> rootfs-origin/etc/init.d/rcS'
	sudo sh -c ' echo "/sbin/mdev -s" >> rootfs-origin/etc/init.d/rcS'
	sudo chmod +x rootfs-origin/etc/init.d/rcS
	sudo mkdir -p rootfs-origin/test
	sudo cp -a scripts/*.sh rootfs-origin/test/
	sudo chmod +x rootfs-origin/test/*.sh
	sudo sh -c ' echo "/test/01_mem_usage.sh" >> rootfs-origin/etc/init.d/rcS'
	sudo sh -c ' echo "/test/02_stress_test.sh" >> rootfs-origin/etc/init.d/rcS'
	sudo sh -c ' echo "/test/03_io_test.sh" >> rootfs-origin/etc/init.d/rcS'
	sudo sh -c ' echo "/test/04_page_faults.sh" >> rootfs-origin/etc/init.d/rcS'
	sudo umount rootfs-origin

obusybox: $(OBUSYBOX)

$(BUILDROOT):
	if [ "$(MENU)" = "y" ]; then \
		echo "Configuring Buildroot with menuconfig..."; \
		make -C buildroot menuconfig; \
	else \
		echo "Skipping Busybox menuconfig (MENU not set to y)"; \
	fi
	make -C buildroot -j$(NPROC)

buildroot: $(BUILDROOT)

$(OBUILDROOT):
	if [ "$(MENU)" = "y" ]; then \
		echo "Configuring Buildroot with menuconfig..."; \
		make -C buildroot-origin menuconfig; \
	else \
		echo "Skipping Busybox menuconfig (MENU not set to y)"; \
	fi
	make -C buildroot-origin -j$(NPROC)

buildroot: $(BUILDROOT)


$(QEMU):
	make -C qemu/build -j$(NPROC)

qemu: $(QEMU)

$(OQEMU):
	make -C qemu-origin/build -j$(NPROC)

oqemu: $(OQEMU)

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

oclean_rootfs:
	rm -rf rootfs-origin
	make -C busybox-origin clean
	rm $(OROOTFS)

oclean_linux:
	make -C linux-origin ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean

oclean_opensbi:
	make -C opensbi-origin clean

oclean_qemu:
	make -C qemu-origin/build clean

oclean:
	make -C linux-origin ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) clean
	make -C opensbi-origin clean
	make -C busybox-origin clean
	make -C qemu-origin/build clean
	rm -rf rootfs
	rm $(OROOTFS)

odistclean:
	make -C linux-origin disclean
	make -C opensbi-origin distclean
	make -C busybox-origin distclean
	make -C qemu-origin/build distclean
	rm -rf rootfs-origin
	rm $(OROOTFS)

.PHONY: clean distclean clean_rootfs clean_linux clean_opensbi clean_qemu linux opensbi rootfs debug gdb debug_qemu oclean odistclean oclean_rootfs oclean_linux oclean_opensbi oclean_qemu olinux oopensbi orootfs
