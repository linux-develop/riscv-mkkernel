# link to qemu
target remote localhost:1234
# load symbol
add-symbol-file ./opensbi/build/platform/generic/firmware/fw_jump.elf 0x80000000
add-symbol-file ./linux/vmlinux 0x80200000
layout split
b *0x80200000

set output-radix 16
