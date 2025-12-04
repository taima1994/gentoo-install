#!/bin/bash
set -e
echo "2. FORMAT VÀ MOUNT CÁC PHÂN VÙNG"

# Format các phân vùng
echo "Formatting /dev/sda1 (root)..."
mkfs.ext4 -F -L GENTOO_ROOT /dev/sda1

echo "Formatting /dev/sda2 (home)..."
mkfs.ext4 -F -L GENTOO_HOME /dev/sda2

echo "Formatting /dev/sdb1 (portage)..."
mkfs.ext4 -F -L GENTOO_PORTAGE /dev/sdb1

# Mount các phân vùng
echo "Mounting partitions..."
mount /dev/sda1 /mnt/gentoo
mkdir -p /mnt/gentoo/{home,var/tmp/portage}
mount /dev/sda2 /mnt/gentoo/home
mount /dev/sdb1 /mnt/gentoo/var/tmp/portage

# Tạo thư mục cần thiết
mkdir -p /mnt/gentoo/{boot,proc,sys,dev}

echo "FORMAT + MOUNT XONG!"
df -h
