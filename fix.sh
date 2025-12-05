#!/bin/bash
set -e
source /etc/profile

# CẤU HÌNH
TARGET_USER="ghost"
HOSTNAME="ghost-pc"
TIMEZONE="Asia/Ho_Chi_Minh"
LOCALE="vi_VN.UTF-8"

echo "========================================"
echo "GHOST 2025 - CÀI ĐẶT TRONG CHROOT"
echo "========================================"

# 1. CẤU HÌNH CƠ BẢN
echo "[1] Cấu hình cơ bản..."

# FSTAB
cat > /etc/fstab << EOF
/dev/sda1    /               ext4    noatime,errors=remount-ro    0 1
/dev/sda2    /home           ext4    defaults,noatime             0 2
/dev/sdb1    /var/tmp/portage ext4  defaults,noatime              0 2
tmpfs        /tmp            tmpfs   defaults,noatime,nosuid,nodev 0 0
EOF

# HOSTNAME
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF

# 2. CẤU HÌNH PORTAGE
echo "[2] Cấu hình Portage..."

# Cập nhật Portage
emerge-webrsync

# Cấu hình make.conf
cat >> /etc/portage/make.conf << EOF
MAKEOPTS="-j\$(nproc)"
EMERGE_DEFAULT_OPTS="--jobs=\$(nproc)"
USE="hardened selinux X wayland pulseaudio dbus elogind networkmanager"
VIDEO_CARDS="amdgpu radeonsi"
INPUT_DEVICES="libinput"
GRUB_PLATFORMS="efi-64"
FEATURES="parallel-fetch parallel-install"
ACCEPT_LICENSE="*"
EOF

# FIX: Xử lý lỗi linux-firmware
mkdir -p /etc/portage/package.{license,unmask}
echo "sys-kernel/linux-firmware linux-fw-redistributable" > /etc/portage/package.license/linux-firmware
echo "=sys-kernel/linux-firmware-20250808" > /etc/portage/package.unmask/linux-firmware

# 3. CẬP NHẬT HỆ THỐNG
echo "[3] Cập nhật @world..."
emerge --update --deep --newuse @world

# 4. CÀI ĐẶT KERNEL VÀ FIRMWARE
echo "[4] Cài đặt kernel và firmware..."

# Cài đặt kernel sources
emerge sys-kernel/gentoo-sources sys-kernel/genkernel

# Cài đặt firmware phiên bản ổn định
emerge =sys-kernel/linux-firmware-20250808

# Compile kernel với genkernel
cd /usr/src/linux
genkernel --kernel-config=/usr/src/linux/.config all

# 5. CẤU HÌNH HỆ THỐNG
echo "[5] Cấu hình hệ thống..."

# Timezone
echo "$TIMEZONE" > /etc/timezone
emerge --config sys-libs/timezone-data

# Locale
echo "vi_VN.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set vi_VN.utf8
env-update && source /etc/profile

# 6. TẠO NGƯỜI DÙNG
echo "[6] Tạo người dùng..."
useradd -m -G wheel,audio,video,portage,usb,cdrom $TARGET_USER
echo "Đặt mật khẩu cho user '$TARGET_USER' (nhập mật khẩu mạnh):"
passwd $TARGET_USER

# Cấu hình sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers.d/10-wheel
chmod 440 /etc/sudoers.d/10-wheel

# 7. CÀI ĐẶT GRUB
echo "[7] Cài đặt GRUB..."
emerge sys-boot/grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# 8. CÀI ĐẶT HYPRLAND
echo "[8] Cài đặt Hyprland..."
emerge gui-wm/hyprland x11-terms/kitty waybar wofi

# 9. CÀI ĐẶT CÔNG CỤ HỆ THỐNG
echo "[9] Cài đặt công cụ hệ thống..."
emerge net-misc/networkmanager net-wireless/iwd sys-auth/elogind sys-apps/dbus
emerge app-editors/neovim sys-process/htop net-misc/openssh

# 10. CẤU HÌNH DỊCH VỤ
echo "[10] Cấu hình dịch vụ..."
rc-update add NetworkManager default
rc-update add dbus default
rc-update add elogind default
rc-update add sshd default

# 11. HOÀN TẤT
echo "========================================"
echo "CÀI ĐẶT HOÀN TẤT!"
echo "========================================"
echo "Thông tin:"
echo "- User: $TARGET_USER"
echo "- Hostname: $HOSTNAME"
echo "- Timezone: $TIMEZONE"
echo "- Locale: $LOCALE"
echo ""
echo "Khởi động lại và đăng nhập với user '$TARGET_USER'"