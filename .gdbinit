# debug linux
# link to qemu
target remote localhost:1234

add-symbol-file ./opensbi/build/platform/generic/firmware/fw_jump.elf 0x80000000

b *0x80201000
b *0x80201044
layout asm

# public
set output-radix 16

# debug qemu
# layout src
# b get_physical_address if (addr > 0xfffffffe00001000)
# tty /dev/pts/1
