# ========================================
# FIX NHANH TẤT CẢ LỖI TRONG CHROOT
# ========================================

# 1. FIX MAKECONF - Lỗi bad substitution
echo "Sửa make.conf..."
cat > /etc/portage/make.conf << 'EOF'
MAKEOPTS="-j2"
EMERGE_DEFAULT_OPTS="--jobs=2"
USE="hardened selinux X wayland pulseaudio dbus elogind networkmanager -openmp"
VIDEO_CARDS="amdgpu radeonsi"
INPUT_DEVICES="libinput"
GRUB_PLATFORMS="efi-64"
FEATURES="parallel-fetch"
ACCEPT_LICENSE="*"
EOF

# 2. CÀI CÁC CÔNG CỤ CƠ BẢN TRƯỚC
echo "Cài công cụ cơ bản..."
emerge -v1 sys-devel/make sys-devel/binutils sys-devel/gcc sys-devel/autoconf sys-devel/automake

# 3. FIX KERNEL SOURCE
echo "Fix kernel source..."
emerge -v1 sys-kernel/gentoo-sources
eselect kernel list
# Nếu có kernel, set nó
eselect kernel set 1 2>/dev/null || true

# 4. CÀI FIRMWARE BẰNG TAY
echo "Cài firmware bằng tay..."
cd /tmp
wget https://mirror.meowsmp.net/gentoo/distfiles/linux-firmware-20250808.tar.xz
tar xf linux-firmware-20250808.tar.xz -C /lib/firmware/
rm linux-firmware-20250808.tar.xz

# 5. CÀI KERNEL BIN (KHÔNG CẦN COMPILE)
echo "Cài kernel binary..."
emerge -v1 sys-kernel/gentoo-kernel-bin

# 6. CÀI CÁC GÓI HỆ THỐNG CƠ BẢN
echo "Cài hệ thống cơ bản..."
emerge -v1 net-misc/dhcpcd net-misc/openssh sys-apps/pciutils sys-apps/usbutils

# 7. CÀI NETWORKMANAGER
echo "Cài NetworkManager..."
emerge -v1 net-misc/networkmanager
rc-update add NetworkManager default

# 8. CÀI GRUB (CHO BIOS, KHÔNG PHẢI UEFI)
echo "Cài GRUB cho BIOS..."
emerge -v1 sys-boot/grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# 9. TẠO FSTAB
echo "Tạo fstab..."
cat > /etc/fstab << 'EOF'
/dev/sda1    /               ext4    defaults,noatime    0 1
/dev/sda2    /home           ext4    defaults,noatime    0 2
/dev/sdb1    /var/tmp/portage ext4  defaults,noatime    0 2
EOF

# 10. CÀI ĐẶT NGƯỜI DÙNG VÀ MẬT KHẨU
echo "Tạo user..."
useradd -m -G wheel,audio,video,portage ghost
echo "Nhập mật khẩu cho user 'ghost':"
passwd ghost

# 11. CÀI HYPRLAND ĐƠN GIẢN
echo "Cài Hyprland minimal..."
cat > /etc/portage/package.use/hyprland-minimal << 'EOF'
gui-wm/hyprland -systemd -qtutils
x11-terms/kitty -wayland
EOF

emerge -v1 gui-wm/hyprland x11-terms/kitty

# 12. CẤU HÌNH CUỐI CÙNG
echo "Cấu hình cuối cùng..."
echo "ghost-pc" > /etc/hostname
rc-update add sshd default
rc-update add dbus default
rc-update add elogind default

echo "=========================================="
echo "FIX HOÀN TẤT! CHẠY CÁC LỆNH SAU:"
echo "1. exit                          # Thoát chroot"
echo "2. umount -R /mnt/gentoo         # Unmount"
echo "3. reboot                        # Khởi động lại"
echo "=========================================="