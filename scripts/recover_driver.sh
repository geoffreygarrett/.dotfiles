#!/bin/bash

# Script for disk imaging and recovery using ddrescue and TestDisk

# Step 1: Create a disk image using ddrescue
create_disk_image() {
    echo "Creating disk image..."
    sudo env "PATH=$PATH" ddrescue -d -r3 /dev/sdb ./disk.img ./rescue.log
}

# Step 2: Analyze and recover partitions using TestDisk
recover_partitions() {
    echo "Analyzing and recovering partitions..."
    sudo env "PATH=$PATH" testdisk ./disk.img << EOF
Proceed
Intel
Analyze
Quick Search
Write
Quit
EOF
}

# Step 3: Recover files using PhotoRec
recover_files() {
    echo "Recovering files..."
    sudo env "PATH=$PATH" photorec ./disk.img
}

# Main execution
echo "Disk Recovery Process"
echo "====================="

create_disk_image
recover_partitions
recover_files

echo "Recovery process completed."