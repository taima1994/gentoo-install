#!/bin/bash
set -e
echo "GHOST 2025 - GENTOO INSTALLER (SIMPLE VERSION)"
echo "=============================================="

# Phần 1: Phân vùng đơn giản như Tecmint
echo "1. Phân vùng đơn giản..."
parted -s /dev/sda mklabel gpt
parted -s /dev/sda mkpart primary 1MiB 201MiB
parted -s /dev/sda set 1 boot on
parted -s /dev/sda mkpart primary 201MiB 100%

# Phần 2: Format và mount
echo "2. Format và mount..."
mkfs.fat -F 32 /dev/sda1
mkfs.ext4 /dev/sda2
mount /dev/sda2 /mnt/gentoo
mkdir /mnt/gentoo/boot
mount /dev/sda1 /mnt/gentoo/boot

# Root trước
mount /dev/sdb3 /mnt/gentoo

# Tạo thư mục và mount boot
mkdir -p /mnt/gentoo/boot
mount /dev/sdb1 /mnt/gentoo/boot

# Tạo và mount thư mục portage temp (SSD - để build nhanh)
mkdir -p /mnt/gentoo/var/tmp/portage
mount /dev/sdb4 /mnt/gentoo/var/tmp/portage

# Mount HDD partitions
mkdir -p /mnt/gentoo/home
mount /dev/sda1 /mnt/gentoo/home

mkdir -p /mnt/gentoo/var/cache/binpkgs
mount /dev/sda2 /mnt/gentoo/var/cache/binpkgs

mkdir -p /mnt/gentoo/var/db/repos/gentoo
mount /dev/sda3 /mnt/gentoo/var/db/repos/gentoo

mkdir -p /mnt/gentoo/mnt/iso-storage
mount /dev/sda4 /mnt/gentoo/mnt/iso-storage
