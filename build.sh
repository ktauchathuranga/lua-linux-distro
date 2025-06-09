#!/bin/bash
gcc -c -Os -fno-ident -fno-asynchronous-unwind-tables -fno-stack-protector -fomit-frame-pointer -o shell.o shell.c
as sys.S -o sys.o
ld -o shell shell.o sys.o --entry main -z noexecstack
mv shell init
echo init | cpio -H newc -o > init.cpio

# make isoimage FDARGS="initrd=/init.cpio" FDINITRD=fun/init.cpio

# echo init >> files
# echo lua >> files
# cat files
# cat files | cpio -H newc -o > init.cpio

# qemu-system-x86_64 -cdrom iso/image.iso

# qemu-system-x86_64 -kernel arch/x86/boot/bzImage

