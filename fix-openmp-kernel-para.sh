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

# FIX: Tạo thư mục package.* trước
mkdir -p /etc/portage/package.{license,unmask,use}

# FIX: Xử lý lỗi linux-firmware
echo "sys-kernel/linux-firmware linux-fw-redistributable" > /etc/portage/package.license/linux-firmware
echo "=sys-kernel/linux-firmware-20250808" > /etc/portage/package.unmask/linux-firmware

# FIX: Xử lý lỗi gettext OpenMP
echo "sys-devel/gettext -openmp" > /etc/portage/package.use/gettext

# Cấu hình make.conf
cat >> /etc/portage/make.conf << EOF
MAKEOPTS="-j2"
EMERGE_DEFAULT_OPTS="--jobs=2 --load-average=2"
USE="hardened selinux X wayland pulseaudio dbus elogind networkmanager -openmp"
VIDEO_CARDS="amdgpu radeonsi"
INPUT_DEVICES="libinput"
GRUB_PLATFORMS="efi-64"
FEATURES="parallel-fetch parallel-install"
ACCEPT_LICENSE="*"
EOF

# 3. CÀI ĐẶT GCC VÀ COMPILER TRƯỚC
echo "[3] Cài đặt compiler và tools cơ bản..."

# Cài các gói compiler cơ bản trước
emerge --oneshot sys-devel/gcc sys-devel/binutils sys-libs/glibc

# Update gcc profile
gcc-config 1
source /etc/profile

# 4. CẬP NHẬT HỆ THỐNG TỪNG PHẦN
echo "[4] Cập nhật hệ thống từng phần..."

# Cập nhật portage và các gói hệ thống cơ bản
emerge --update --deep --newuse sys-apps/portage sys-devel/make sys-devel/autoconf sys-devel/automake

# 5. CÀI ĐẶT KERNEL VÀ FIRMWARE
echo "[5] Cài đặt kernel và firmware..."

# Cài đặt kernel sources
emerge sys-kernel/gentoo-sources

# FIX: Tạo symlink cho kernel source
eselect kernel set 1
cd /usr/src/linux

# Cài đặt firmware phiên bản ổn định
emerge =sys-kernel/linux-firmware-20250808

# 6. COMPILE KERNEL ĐƠN GIẢN
echo "[6] Compile kernel với config mặc định..."

# Sử dụng config từ distribution
cp /usr/src/linux/.config /usr/src/linux/.config.backup
make defconfig

# FIX: Bật các options cần thiết
./scripts/config --set-val CONFIG_MODULES y
./scripts/config --set-val CONFIG_BLK_DEV_INITRD y
./scripts/config --set-val CONFIG_DEVTMPFS y
./scripts/config --set-val CONFIG_DEVTMPFS_MOUNT y

# Compile kernel
make -j2
make modules_install
make install

# 7. CẤU HÌNH HỆ THỐNG
echo "[7] Cấu hình hệ thống..."

# Timezone
echo "$TIMEZONE" > /etc/timezone
emerge --config sys-libs/timezone-data

# Locale
echo "vi_VN.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set vi_VN.utf8
env-update && source /etc/profile

# 8. TẠO NGƯỜI DÙNG
echo "[8] Tạo người dùng..."
useradd -m -G wheel,audio,video,portage,usb,cdrom $TARGET_USER
echo "Đặt mật khẩu cho user '$TARGET_USER' (nhập mật khẩu mạnh):"
passwd $TARGET_USER

# Cấu hình sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers.d/10-wheel
chmod 440 /etc/sudoers.d/10-wheel

# 9. CÀI ĐẶT GRUB
echo "[9] Cài đặt GRUB..."
emerge sys-boot/grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# 10. CÀI ĐẶT CÁC GÓI HỆ THỐNG CƠ BẢN
echo "[10] Cài đặt các gói hệ thống..."

# Cài đặt network và essential packages
emerge net-misc/networkmanager \
        net-wireless/iwd \
        sys-auth/elogind \
        sys-apps/dbus \
        app-editors/neovim \
        sys-process/htop \
        net-misc/openssh \
        net-misc/dhcpcd \
        sys-apps/pciutils \
        sys-apps/usbutils

# 11. CÀI ĐẶT HYPRLAND (KHÔNG CẦN OPENMP)
echo "[11] Cài đặt Hyprland..."

# Tạm thời disable các USE flags gây lỗi
echo "gui-wm/hyprland -systemd" >> /etc/portage/package.use/hyprland
echo "x11-terms/kitty -wayland" >> /etc/portage/package.use/kitty

# Cài đặt với minimal dependencies
USE="-openmp" emerge gui-wm/hyprland x11-terms/kitty waybar wofi

# 12. CẤU HÌNH DỊCH VỤ
echo "[12] Cấu hình dịch vụ..."
rc-update add NetworkManager default
rc-update add dbus default
rc-update add elogind default
rc-update add sshd default
rc-update add dhcpcd default

# 13. HOÀN TẤT
echo "========================================"
echo "CÀI ĐẶT HOÀN TẤT!"
echo "========================================"
echo "Thông tin hệ thống:"
echo "- User: $TARGET_USER"
echo "- Hostname: $HOSTNAME"
echo "- Timezone: $TIMEZONE"
echo "- Locale: $LOCALE"
echo "- Kernel: $(ls /lib/modules/)"
echo ""
echo "LỆNH SAU KHI REBOOT:"
echo "1. Đăng nhập: ghost"
echo "2. Khởi động mạng: sudo rc-service NetworkManager start"
echo "3. Cấu hình WiFi: sudo nmtui"
echo ""
echo "Chạy lệnh sau để thoát và reboot:"
echo "exit"
echo "umount -R /mnt/gentoo"
echo "reboot"