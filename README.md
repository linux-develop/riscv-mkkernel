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
$ make all MENU=y
```

# only compile linux
``` bash
# first try
$ make linux MENU=y

# later
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

# later
$ make rootfs
```

# only compile qemu
``` bash
# first try
$ cd qemu
$ mkdir -p build
$ cd build
$ ../configure
$ make

# later
$ make qemu
```
