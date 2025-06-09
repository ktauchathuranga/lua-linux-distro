# Minimal Linux Distribution with Custom Shell and Lua

This repository contains a minimal Linux distribution built from scratch, featuring a custom shell and the Lua interpreter, packaged into a bootable ISO image. The distribution uses the Linux 6.15.1 kernel and can be tested using QEMU.

## Overview

This project creates a lightweight Linux system that boots into a custom shell (`init`) implemented in C and assembly. The shell supports basic command execution using system calls (`fork`, `execve`, `waitid`, etc.) and is packaged into an initramfs (`init.cpio`). The Lua interpreter is included, allowing users to run Lua scripts in the environment. The system is built into a bootable ISO image for testing with QEMU or on real hardware.

## Features
- Custom shell written in C (`shell.c`) with x86_64 assembly system call wrappers (`sys.S`).
- Minimal initramfs (`init.cpio`) containing the shell and Lua interpreter.
- Bootable ISO image generated using the Linux 6.15.1 kernel.
- Tested with QEMU for easy development and debugging.
- Lightweight and optimized build with no stack protection and non-executable stack.

## Prerequisites
- **Arch Linux** (or another Linux distribution with adjustments).
- **Linux Kernel Source**: Linux 6.15.1 (place in `~/linux-iso/linux-6.15.1`).
- **Build Tools**:
  ```bash
  sudo pacman -S base-devel gcc make cpio syslinux cdrtools
  ```
- **QEMU**:
  ```bash
  sudo pacman -S qemu-system-x86
  ```
- **Optional (for Lua)**: Ensure the `lua` binary is available in the `work` directory or initramfs.

## Repository Structure
- `build.sh`: Script to compile `shell.c`, assemble `sys.S`, link the executable, and create `init.cpio`.
- `shell.c`: C source for the custom shell, implementing a command-line interface.
- `sys.S`: x86_64 assembly code providing system call wrappers.
- `init`: The compiled shell executable, used as the init process.
- `init.cpio`: The initramfs archive containing `init` and `lua`.
- `lua`: Lua interpreter binary (included in the initramfs).
- `iso/`: Directory containing the built ISO image (`image.iso`).
- `shell.o`, `sys.o`: Intermediate object files from compilation.
- `files`: Optional file list for initramfs creation (commented in `build.sh`).

## Build Instructions
1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. **Prepare the Linux Kernel**:
   - Download and extract the Linux 6.15.1 kernel source to `~/linux-iso/linux-6.15.1`.
   - Configure and build the kernel:
     ```bash
     cd ~/linux-iso/linux-6.15.1
     make defconfig
     make -j4
     ```

3. **Build the Shell and Initramfs**:
   - Ensure `lua` is in the `work` directory (or modify `init.cpio` to include it).
   - Run the build script:
     ```bash
     chmod +x build.sh
     ./build.sh
     ```
   This compiles `shell.c`, assembles `sys.S`, links them into `init`, and creates `init.cpio`.

4. **Create the Bootable ISO**:
   - In the kernel source directory:
     ```bash
     cd ~/linux-iso/linux-6.15.1
     make isoimage FDARGS="initrd=/init.cpio" FDINITRD=~/<repository-path>/work/init.cpio
     ```
   The ISO will be created at `arch/x86/boot/image.iso`.

## Usage
1. **Test with QEMU (Serial Console)**:
   ```bash
   qemu-system-x86_64 -cdrom ~/linux-iso/linux-6.15.1/arch/x86/boot/image.iso -nographic -serial mon:stdio -append "console=ttyS0"
   ```
   - This boots the ISO, displaying the shell prompt (`#`) in the terminal.
   - Type commands (e.g., `lua` to run the Lua interpreter, if included).

2. **Test with QEMU (Graphical Output)**:
   ```bash
   qemu-system-x86_64 -cdrom ~/linux-iso/linux-6.15.1/arch/x86/boot/image.iso
   ```
   - Connect to the VNC server:
     ```bash
     vncviewer localhost:5900
     ```

3. **Run Commands**:
   - At the `#` prompt, enter commands like `/bin/lua` (if `lua` is in the initramfs) or other executables included in `init.cpio`.
   - Note: The shell requires commands to be full paths (e.g., `/bin/lua`).

## Adding Lua to the Initramfs
To include the Lua interpreter in `init.cpio`:
1. Copy the `lua` binary to an initramfs directory:
   ```bash
   mkdir -p initramfs/bin
   cp lua initramfs/bin/lua
   cp init initramfs/init
   ```
2. Create the `cpio` archive:
   ```bash
   cd initramfs
   find . | cpio -o -H newc > ../init.cpio
   ```
3. Rebuild the ISO as shown above.

## Notes
- The shell (`shell.c`) is minimal and expects commands with full paths (e.g., `/bin/lua`).
- Ensure the Linux kernel is configured with serial console support (`CONFIG_SERIAL_8250_CONSOLE=y`) for `-nographic` output.
- If the kernel panics (e.g., “No init found”), verify `init.cpio` contains a valid `/init` executable.
- The `files` file and commented lines in `build.sh` are optional and can be used to customize the initramfs.

## Credits
- Based on the YouTube tutorial ["Writing a Simple Operating System from Scratch - Part 2: Writing a Shell"](https://www.youtube.com/watch?v=u2Juz5sQyYQ) by The CS Guy.
- Extended with Lua interpreter integration for additional functionality.

## Contributing
Feel free to submit issues or pull requests to improve the shell, add features, or enhance documentation.

---

**Note**: This is an educational project designed to demonstrate low-level Linux programming concepts. It is not intended for production use.

