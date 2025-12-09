#!/bin/bash
# Script1-Simple: Partition Dual (sdb SSD system, sda HDD data) - No pip, debug echo

echo "=== GHOST1: Bắt đầu phân vùng sdb (SSD) ==="
echo "o
n
p
1

+512M
t
1
ef
n
p
2

+8G
t
2
82
n
p
3

+100G
t
3
83
n
p
4


t
4
83
w" | fdisk /dev/sdb
echo "Phân vùng sdb OK"

echo "Format sdb:"
mkfs.vfat -F32 /dev/sdb1
mkswap /dev/sdb2
mkfs.ext4 /dev/sdb3
mkfs.ext4 /dev/sdb4
echo "Format sdb OK"

echo "=== GHOST1: Phân vùng sda (HDD) ==="
echo "o
n
p
1

+465G
t
1
83
n
p
2


t
2
83
w" | fdisk /dev/sda
echo "Phân vùng sda OK"

mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/sda2
echo "Format sda OK"

echo "Mount sdb:"
mount /dev/sdb3 /mnt/gentoo
mkdir -p /mnt/gentoo/{boot,var}
mount /dev/sdb1 /mnt/gentoo/boot
mount /dev/sdb4 /mnt/gentoo/var
swapon /dev/sdb2
echo "Mount OK. Check: lsblk"

echo "=== GHOST1 HOÀN THÀNH! Chạy Script2 ==="