#!/bin/bash
set -e
source /etc/profile

echo "========================================"
echo "GHOST 2025 - CÀI ĐẶT TRONG CHROOT"
echo "========================================"

# 1. Cấu hình Portage và fix lỗi
echo "1. Cấu hình Portage và fix lỗi..."
emerge-webrsync

# Tạo thư mục package.* trước
mkdir -p /etc/portage/package.{use,unmask,license,mask}

# ========== FIX LỖI SYSTEMD QUAN TRỌNG ==========
echo "sys-apps/systemd" > /etc/portage/package.mask/systemd
echo "virtual/systemd" > /etc/portage/package.mask/virtual-systemd
echo "sys-apps/systemd-utils" > /etc/portage/package.mask/systemd-utils

# FIX LỖI GETTEXT
echo "sys-devel/gettext -openmp" > /etc/portage/package.use/gettext

# FIX LỖI FIRMWARE
echo "sys-kernel/linux-firmware linux-fw-redistributable" > /etc/portage/package.license/linux-firmware
echo "=sys-kernel/linux-firmware-20250808" > /etc/portage/package.unmask/linux-firmware

# ========== CẤU HÌNH USE FLAGS TRÁNH SYSTEMD ==========
cat > /etc/portage/package.use/avoid-systemd << 'EOF'
# Tránh systemd hoàn toàn
sys-apps/dbus -systemd
sys-apps/util-linux -systemd
virtual/libudev -systemd
sec-policy/selinux-base-policy -systemd
app-text/docbook-xml-dtd -systemd
app-text/build-docbook-catalog -systemd
sys-apps/man-db -systemd
sys-apps/groff -systemd
sys-apps/texinfo -systemd
app-editors/emacs -systemd
EOF

# FIX LỖI MAKE.CONF - ĐƠN GIẢN
cat > /etc/portage/make.conf << 'EOF'
MAKEOPTS="-j2"
USE="hardened selinux X wayland pulseaudio dbus elogind networkmanager -openmp -systemd -gnome -kde -plymouth"
VIDEO_CARDS="amdgpu radeonsi"
INPUT_DEVICES="libinput"
GRUB_PLATFORMS="efi-64"
ACCEPT_LICENSE="*"
EOF

# 2. Cập nhật hệ thống
echo "2. Cập nhật hệ thống..."
emerge --update --deep --newuse @world

# 3. Cài kernel BINARY để KHÔNG LỖI
echo "3. Cài kernel binary..."
emerge sys-kernel/gentoo-kernel-bin

# 4. Cài firmware phiên bản ổn định
echo "4. Cài firmware..."
emerge =sys-kernel/linux-firmware-20250808

# 5. Cấu hình hệ thống
echo "5. Cấu hình hệ thống..."

# FSTAB - QUAN TRỌNG
cat > /etc/fstab << 'EOF'
/dev/sda1    /               ext4    defaults,noatime    0 1
/dev/sda2    /home           ext4    defaults,noatime    0 2
/dev/sdb1    /var/tmp/portage ext4  defaults,noatime    0 2
EOF

# Hostname
echo "ghost-pc" > /etc/hostname
cat > /etc/hosts << 'EOF'
127.0.0.1   localhost
::1         localhost
127.0.1.1   ghost-pc.localdomain ghost-pc
EOF

# Timezone
echo "Asia/Ho_Chi_Minh" > /etc/timezone

# Locale
echo "vi_VN.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set vi_VN.utf8
env-update && source /etc/profile

# 6. Cài GRUB
echo "6. Cài GRUB..."
emerge sys-boot/grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# 7. Tạo user
echo "7. Tạo người dùng..."
useradd -m -G wheel,audio,video,portage,usb ghost
echo "ghost:ghost" | chpasswd

# Cấu hình sudo
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel

# 8. Cài các công cụ hệ thống (ELOGIND thay vì SYSTEMD)
echo "8. Cài công cụ hệ thống..."

# Cài dbus không systemd
cat > /etc/portage/package.use/dbus << 'EOF'
sys-apps/dbus -systemd elogind
EOF

emerge sys-apps/dbus
emerge sys-auth/elogind
emerge app-editors/neovim
emerge net-misc/networkmanager

# 9. Cài Hyprland (FIX LỖI)
echo "9. Cài Hyprland..."

# Thêm USE flags cho Hyprland
cat > /etc/portage/package.use/hyprland-fix << 'EOF'
gui-wm/hyprland -systemd elogind
x11-terms/kitty -wayland
gui-apps/waybar tray
EOF

emerge gui-wm/hyprland x11-terms/kitty waybar wofi

# 10. Cài SSH và dịch vụ
echo "10. Cài SSH và dịch vụ..."
emerge net-misc/openssh
emerge sys-apps/catalyst

# 11. Cấu hình dịch vụ
echo "11. Cấu hình dịch vụ..."
rc-update add sshd default
rc-update add NetworkManager default
rc-update add dbus default
rc-update add elogind default

echo "========================================"
echo "✅ CÀI ĐẶT HOÀN TẤT!"
echo "========================================"
echo "User: ghost"
echo "Password: ghost"
echo "Hostname: ghost-pc"
echo ""
echo "Khởi động lại và đăng nhập với user 'ghost'"
CHROOT_EOF

chmod +x /mnt/gentoo/install-inside.sh
chroot /mnt/gentoo /bin/bash /install-inside.sh

echo "=============================="
echo "HOÀN TẤT! Chạy lệnh sau:"
echo "exit"
echo "umount -R /mnt/gentoo"