# link to qemu
target remote localhost:1234
# load symbol
add-symbol-file ./opensbi/build/platform/generic/firmware/fw_jump.elf 0x80000000
layout asm
b *0x80200000

set output-radix 16
