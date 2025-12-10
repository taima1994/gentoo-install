#!/bin/bash
# AUTO PARTITION FOR GENTOO BUILD SYSTEM
# SSD: sdb (223G) - HDD: sda (931G)

echo "=== GENTOO AUTO PARTITION SCRIPT ==="
echo "WARNING: This will DESTROY ALL DATA on /dev/sda and /dev/sdb!"
read -p "Continue? (type 'YES' to confirm): " confirm

if [ "$confirm" != "YES" ]; then
    echo "Aborted."
    exit 1
fi

echo "=== STEP 1: Clean disks ==="
wipefs -a /dev/sda
wipefs -a /dev/sdb
partprobe

echo "=== STEP 2: Partition SSD (sdb) ==="
# GPT table for UEFI
parted -s /dev/sdb mklabel gpt
# 1G boot
parted -s /dev/sdb mkpart primary fat32 1MiB 1025MiB
parted -s /dev/sdb set 1 esp on
# 16G swap
parted -s /dev/sdb mkpart primary linux-swap 1025MiB 17409MiB
# 50G root
parted -s /dev/sdb mkpart primary ext4 17409MiB 68609MiB
# Rest for portage temp
parted -s /dev/sdb mkpart primary ext4 68609MiB 100%

echo "=== STEP 3: Partition HDD (sda) ==="
parted -s /dev/sda mklabel gpt
# 200G home
parted -s /dev/sda mkpart primary ext4 1MiB 200GiB
# 100G binpkgs
parted -s /dev/sda mkpart primary ext4 200GiB 300GiB
# 50G portage tree
parted -s /dev/sda mkpart primary ext4 300GiB 350GiB
# Rest for ISO storage
parted -s /dev/sda mkpart primary ext4 350GiB 100%

echo "=== STEP 4: Format partitions ==="
# SSD
mkfs.fat -F 32 /dev/sdb1
mkswap /dev/sdb2
swapon /dev/sdb2
mkfs.ext4 -F /dev/sdb3
mkfs.ext4 -F /dev/sdb4
# HDD
mkfs.ext4 -F /dev/sda1
mkfs.ext4 -F /dev/sda2
mkfs.ext4 -F /dev/sda3
mkfs.ext4 -F /dev/sda4

echo "=== STEP 5: Optimize SSD ==="
tune2fs -o discard /dev/sdb3
tune2fs -o discard /dev/sdb4

echo "=== STEP 6: Mount everything ==="
mount /dev/sdb3 /mnt/gentoo
mkdir -p /mnt/gentoo/{boot,var/tmp/portage,home,var/cache/binpkgs,var/db/repos,mnt/iso-storage}
mount /dev/sdb1 /mnt/gentoo/boot
mount /dev/sdb4 /mnt/gentoo/var/tmp/portage
mount /dev/sda1 /mnt/gentoo/home
mount /dev/sda2 /mnt/gentoo/var/cache/binpkgs
mount /dev/sda3 /mnt/gentoo/var/db/repos
mount /dev/sda4 /mnt/gentoo/mnt/iso-storage

echo "=== STEP 7: Verify ==="
lsblk
df -h

echo "=== DONE! Partitions ready. ==="
echo "Boot: /dev/sdb1 (1G)"
echo "Swap: /dev/sdb2 (16G)"
echo "Root: /dev/sdb3 (50G)"
echo "Portage temp: /dev/sdb4 (150G)"
echo "Home: /dev/sda1 (200G)"
echo "Binary cache: /dev/sda2 (100G)"
echo "Portage tree: /dev/sda3 (50G)"
echo "ISO storage: /dev/sda4 (580G)"

# 3.1 Chuyển vào thư mục mount
cd /mnt/gentoo

# 3.2 Tải stage3 mới nhất (chọn đúng kiến trúc)
links https://www.gentoo.org/downloads/
# Hoặc dùng wget:
wget https://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-desktop-openrc.txt
# Xem file vừa tải để biết tên stage3 chính xác

# 3.3 Tải stage3
wget [URL_STAGE3_TỪ_FILE_TRÊN]

# 3.4 Giải nén
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
