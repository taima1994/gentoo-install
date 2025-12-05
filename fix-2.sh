# ========================================
# 1. FIX LỖI GETTEXT OPENMP
# ========================================
echo "sys-devel/gettext -openmp" > /etc/portage/package.use/gettext

# ========================================
# 2. FIX LỖI LINUX-FIRMWARE
# ========================================
mkdir -p /etc/portage/package.{license,unmask}
echo "sys-kernel/linux-firmware linux-fw-redistributable" > /etc/portage/package.license/linux-firmware
echo "=sys-kernel/linux-firmware-20250808" > /etc/portage/package.unmask/linux-firmware

# ========================================
# 3. CẬP NHẬT MAKE.CONF
# ========================================
cat >> /etc/portage/make.conf << 'EOF'
MAKEOPTS="-j2"
EMERGE_DEFAULT_OPTS="--jobs=2 --load-average=2"
USE="hardened selinux X wayland pulseaudio dbus elogind networkmanager -openmp"
ACCEPT_LICENSE="*"
EOF

# ========================================
# 4. CÀI ĐẶT FIRMWARE TRƯỚC
# ========================================
emerge =sys-kernel/linux-firmware-20250808

# ========================================
# 5. CÀI ĐẶT KERNEL SOURCES ĐÚNG CÁCH
# ========================================
emerge sys-kernel/gentoo-sources
eselect kernel set 1
cd /usr/src/linux

# ========================================
# 6. COMPILE KERNEL ĐƠN GIẢN
# ========================================
cp /usr/src/linux/.config /usr/src/linux/.config.backup
make defconfig

# Bật các options cần thiết
./scripts/config --set-val CONFIG_MODULES y
./scripts/config --set-val CONFIG_BLK_DEV_INITRD y
./scripts/config --set-val CONFIG_DEVTMPFS y
./scripts/config --set-val CONFIG_DEVTMPFS_MOUNT y

make -j2
make modules_install
make install

# ========================================
# 7. CÀI ĐẶT CÁC GÓI CƠ BẢN
# ========================================
emerge net-misc/networkmanager net-wireless/iwd sys-auth/elogind sys-apps/dbus
emerge net-misc/openssh net-misc/dhcpcd

# ========================================
# 8. CÀI HYPRLAND (KHÔNG CẦN OPENMP)
# ========================================
echo "gui-wm/hyprland -systemd" >> /etc/portage/package.use/hyprland
echo "x11-terms/kitty -wayland" >> /etc/portage/package.use/kitty

USE="-openmp" emerge gui-wm/hyprland x11-terms/kitty waybar wofi

# ========================================
# 9. CẤU HÌNH DỊCH VỤ
# ========================================
rc-update add NetworkManager default
rc-update add dbus default
rc-update add elogind default
rc-update add sshd default
rc-update add dhcpcd default

# ========================================
# 10. CÀI GRUB
# ========================================
emerge sys-boot/grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

echo "FIX HOÀN TẤT! Chạy lệnh:"
echo "exit"
echo "umount -R /mnt/gentoo"
echo "reboot"