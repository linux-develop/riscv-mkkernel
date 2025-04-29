# prequirements
```
$ sudo apt install libncurses-dev flex bison gcc-riscv64-linux-gnu qemu-utils python3-pip libxen-deva libglib2.0-dev
$ pip3 install tomli sphinx ninja
```

# clone the main repo
``` bash
$ git clone git@github.com:linux-develop/riscv-mkkernel.git
```

# clone all the submodule
``` bash
$ git submodule update --init --recursive
```

# compile all the project
``` bash
# first try
$ cd qemu
$ mkdir -p build
$ cd build
$ ../configure --target-list=riscv64-softmmu
```
> choose `build static binary` in busybox's menuconfig

## next time in top directory
``` bash
$ make all MENU=y
```

# only compile linux
``` bash
# first try in top directory
$ make linux MENU=y

# next time in top directory
$ make linux
```

# only compile opensbi
``` bash
# in top directory
$ make opensbi
```

## enable debug mode
``` bash
$ make opensbi DEBUG=y
```

# only compile rootfs
``` bash
# first try in top directory
$ make rootfs MENU=y

# next time in top directory
$ make rootfs
```

# only compile qemu
``` bash
# first try
$ cd qemu
$ mkdir -p build
$ cd build
$ ../configure --target-list=riscv64-softmmu
$ make -j$(nproc)

# next time in top directory
$ make qemu
```

## enable debug mode
```bash
$ ../configure --target-list=riscv64-softmmu --enable-debug --enable-debug-tcg
```
