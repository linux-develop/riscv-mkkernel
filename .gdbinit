# debug linux
# link to qemu
target remote localhost:1234
add-symbol-file ./opensbi/build/platform/generic/firmware/fw_jump.elf 0x80000000

# relocate_enable_mmu
# b *0x82001000
# _start
# b *0x82000000
b setup_vm_final
b setup_bootmem

layout split

# public
set output-radix 16

# debug qemu
# layout src
# b get_physical_address if (addr > 0xfffffffe00001000)
# tty /dev/pts/2
