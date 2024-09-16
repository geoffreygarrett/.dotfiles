#!/bin/bash

# QEMU parameters
MEMORY="2G"
DISK="nixos-disk.qcow2"
ISO="nixos-minimal-24.05.4847.44a71ff39c18-aarch64-linux.iso"
BIOS="/nix/store/0xcphynas8pri92b6shczg2qhp51b3v9-qemu-9.1.0/share/qemu/edk2-aarch64-code.fd"
CPU="cortex-a72"

qemu-system-aarch64 \
    -M virt,highmem=off \
    -accel hvf \
    -m "$MEMORY" \
    -drive file="$DISK",if=virtio \
    -cdrom "$ISO" \
    -boot d \
    -serial stdio \
    -bios "$BIOS" \
    -boot menu=on \
    -cpu "$CPU" \
    -device virtio-net-pci \
    -nic user,model=virtio-net-pci \
    -device virtio-rng-pci \
    -usb \
    -device usb-tablet \
    -nodefaults \
    -nographic