# debug linux
# link to qemu
target remote localhost:1234
add-symbol-file ./opensbi/build/platform/generic/firmware/fw_jump.elf 0x80000000

# set_satp_mode
# b *0x80c0606e
# relocate_enable_mmu
b *0x80201000
# csrw satp, a5
# b *0x80c061d6
# setup_vm
b *0x80c0644e

layout asm

# public
set output-radix 16

# debug qemu
# layout src
# b get_physical_address if (addr > 0xfffffffe00001000)
# tty /dev/pts/2
