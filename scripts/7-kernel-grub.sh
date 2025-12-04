#!/bin/bash
set -e
echo "7. CẤU HÌNH KERNEL + GRUB"

# Cài đặt kernel và firmware
emerge sys-kernel/gentoo-sources sys-kernel/genkernel sys-boot/grub linux-firmware

# Cấu hình kernel với genkernel
cd /usr/src/linux
genkernel --menuconfig --makeopts="-j$(nproc)" --no-mrproper --no-save-config --kernel-config=/proc/config.gz all

# Đảm bảo có đủ firmware
emerge sys-kernel/linux-firmware

# Cài đặt GRUB
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Cấu hình modules
echo 'MODULES="amdgpu radeon"' >> /etc/conf.d/modules
rc-update add modules boot

echo "KERNEL + GRUB XONG!"
