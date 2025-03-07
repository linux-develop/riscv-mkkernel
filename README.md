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

# next time
$ make all MENU=y
```

# only compile linux
``` bash
# first try
$ make linux MENU=y

# next time
$ make linux
```

# only compile opensbi
``` bash
$ make opensbi
```

# only compile rootfs
``` bash
# first try
$ make rootfs MENU=y

# next time
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

# next time
$ make qemu
```
