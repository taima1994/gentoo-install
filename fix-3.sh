# ==============================================================================
# PHẦN 4: CHUẨN BỊ CHROOT
# ==============================================================================
echo "🏗️  4. Chuẩn bị chroot..."

# Mount các filesystem cần thiết
mount --types proc /proc $WORKDIR/proc
mount --rbind /sys $WORKDIR/sys
mount --make-rslave $WORKDIR/sys
mount --rbind /dev $WORKDIR/dev
mount --make-rslave $WORKDIR/dev
cp -L /etc/resolv.conf $WORKDIR/etc/

# ==============================================================================
# PHẦN 5: SCRIPT CHROOT - HOÀN CHỈNH VỚI TẤT CẢ FIX
# ==============================================================================
cat > $WORKDIR/install-inside.sh << 'CHROOT_EOF'
#!/bin/bash
set -euo pipefail

# ==============================================================================
# CẤU HÌNH
# ==============================================================================
TARGET_USER="ghost"
HOSTNAME="ghost-pc"
TIMEZONE="Asia/Ho_Chi_Minh"
LOCALE="vi_VN.UTF-8"
KEYMAP="us"

echo "========================================"
echo "🚀 GHOST 2025 - CÀI ĐẶT TRONG CHROOT"
echo "========================================"

# ==============================================================================
# 1. FIX CƠ BẢN & CẤU HÌNH PORTAGE
# ==============================================================================
echo "🔧 [1/12] Cấu hình Portage và fix lỗi cơ bản..."

# TẮT SANDBOX - FIX LỖI SANDBOX
cat > /etc/portage/make.conf << 'MAKE_CONF_EOF'
MAKEOPTS="-j2"
EMERGE_DEFAULT_OPTS="--jobs=2 --load-average=2"
USE="hardened selinux X wayland pulseaudio dbus elogind networkmanager -openmp"
VIDEO_CARDS="amdgpu radeonsi"
INPUT_DEVICES="libinput"
GRUB_PLATFORMS="efi-64"
FEATURES="-sandbox -usersandbox parallel-fetch"
ACCEPT_LICENSE="*"
MAKE_CONF_EOF

# Tạo thư mục package.*
mkdir -p /etc/portage/package.{use,unmask,license,accept_keywords}

# FIX LỖI GETTEXT OPENMP
echo "sys-devel/gettext -openmp" > /etc/portage/package.use/gettext

# FIX LỖI HYPRLAND
cat > /etc/portage/package.use/hyprland-fix << 'USE_EOF'
gui-wm/hyprland -systemd
x11-terms/kitty -wayland
media-libs/freetype harfbuzz
x11-libs/libdrm video_cards_radeon
kde-frameworks/solid qml
dev-qt/qtbase opengl
dev-qt/qtdeclarative opengl
app-text/ghostscript -jpeg2k
USE_EOF

# ==============================================================================
# 2. CẬP NHẬT PORTAGE & CÀI CÔNG CỤ CƠ BẢN
# ==============================================================================
echo "📦 [2/12] Cập nhật Portage và cài công cụ cơ bản..."

emerge-webrsync

# Cài compiler và tools cơ bản trước
emerge -v1 sys-devel/gcc sys-devel/binutils sys-devel/make sys-libs/glibc
gcc-config 1
source /etc/profile

# ==============================================================================
# 3. CÀI FIRMWARE TRỰC TIẾP TỪ KERNEL.ORG
# ==============================================================================
echo "💾 [3/12] Cài đặt firmware..."

# Tạo rule cho firmware
echo "sys-kernel/linux-firmware linux-fw-redistributable" > /etc/portage/package.license/linux-firmware
echo "=sys-kernel/linux-firmware-20250808" > /etc/portage/package.unmask/linux-firmware

# Nếu emerge lỗi, tải firmware bằng tay
if ! emerge =sys-kernel/linux-firmware-20250808; then
    echo "⚠️  Emerge firmware thất bại, tải bằng tay từ kernel.org..."
    cd /lib
    mkdir -p firmware
    cd firmware
    wget -q https://mirrors.edge.kernel.org/pub/linux/kernel/firmware/linux-firmware-20250808.tar.xz
    tar xf linux-firmware-20250808.tar.xz --strip-components=1
    rm linux-firmware-20250808.tar.xz
fi

# ==============================================================================
# 4. CÀI VÀ COMPILE KERNEL
# ==============================================================================
echo "🐧 [4/12] Cài đặt và compile kernel..."

# Cài kernel sources từ git gentoo
emerge sys-kernel/gentoo-sources

# Đảm bảo có symlink kernel
eselect kernel list 2>/dev/null || true
cd /usr/src
if [ ! -d "linux" ]; then
    ln -s linux-* linux 2>/dev/null || ln -s linux-6.* linux
fi

# Compile kernel đơn giản
cd /usr/src/linux
make defconfig

# Bật options cần thiết
./scripts/config --set-val CONFIG_MODULES y
./scripts/config --set-val CONFIG_BLK_DEV_INITRD y
./scripts/config --set-val CONFIG_DEVTMPFS y
./scripts/config --set-val CONFIG_DEVTMPFS_MOUNT y

# Compile với 2 jobs để tránh lỗi
make -j2
make modules_install
make install

# ==============================================================================
# 5. CẬP NHẬT HỆ THỐNG
# ==============================================================================
echo "🔄 [5/12] Cập nhật hệ thống..."

emerge --update --deep --newuse @world

# ==============================================================================
# 6. CẤU HÌNH HỆ THỐNG CƠ BẢN
# ==============================================================================
echo "⚙️  [6/12] Cấu hình hệ thống cơ bản..."

# FSTAB
cat > /etc/fstab << 'FSTAB_EOF'
/dev/sda1    /               ext4    noatime,errors=remount-ro    0 1
/dev/sda2    /home           ext4    defaults,noatime             0 2
/dev/sdb1    /var/tmp/portage ext4  defaults,noatime              0 2
tmpfs        /tmp            tmpfs   defaults,noatime,nosuid,nodev 0 0
FSTAB_EOF

# Hostname
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts << 'HOSTS_EOF'
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS_EOF

# Timezone
echo "$TIMEZONE" > /etc/timezone
emerge --config sys-libs/timezone-data

# Locale
echo "vi_VN.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set vi_VN.utf8
env-update && source /etc/profile

# Keymap
echo "keymap=\"$KEYMAP\"" > /etc/conf.d/keymaps

# ==============================================================================
# 7. CÀI ĐẶT GRUB
# ==============================================================================
echo "👢 [7/12] Cài đặt GRUB..."

emerge sys-boot/grub

# Cài GRUB cho BIOS
grub-install /dev/sda

# Tạo config GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# ==============================================================================
# 8. TẠO NGƯỜI DÙNG VÀ CẤU HÌNH SUDO
# ==============================================================================
echo "👤 [8/12] Tạo người dùng..."

useradd -m -G wheel,audio,video,portage,usb,cdrom $TARGET_USER
echo "🔐 Nhập mật khẩu cho user '$TARGET_USER' (nhập mật khẩu mạnh):"
passwd $TARGET_USER

# Cấu hình sudo
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/10-wheel
chmod 440 /etc/sudoers.d/10-wheel

# ==============================================================================
# 9. CÀI ĐẶT MÔI TRƯỜNG ĐỒ HỌA
# ==============================================================================
echo "🎨 [9/12] Cài đặt Hyprland và ứng dụng..."

# Cài Hyprland minimal
emerge gui-wm/hyprland \
       x11-terms/kitty \
       gui-apps/waybar \
       gui-apps/wofi \
       x11-misc/xdg-user-dirs

# ==============================================================================
# 10. CÀI ĐẶT CÔNG CỤ HỆ THỐNG
# ==============================================================================
echo "🛠️  [10/12] Cài đặt công cụ hệ thống..."

# Network
emerge net-misc/networkmanager \
        net-wireless/iwd

# System tools
emerge sys-auth/elogind \
       sys-apps/dbus \
       app-editors/neovim \
       sys-process/htop \
       net-misc/openssh \
       net-misc/dhcpcd \
       sys-apps/pciutils \
       sys-apps/usbutils \
       sys-power/acpid \
       sys-block/parted \
       sys-fs/e2fsprogs

# ==============================================================================
# 11. CẤU HÌNH DỊCH VỤ
# ==============================================================================
echo "⚡ [11/12] Cấu hình dịch vụ..."

rc-update add NetworkManager default
rc-update add dbus default
rc-update add elogind default
rc-update add sshd default
rc-update add dhcpcd default
rc-update add acpid default

# Tạo thư mục người dùng
su - $TARGET_USER -c "xdg-user-dirs-update" || true

# ==============================================================================
# 12. HOÀN TẤT VÀ THÔNG TIN
# ==============================================================================
echo "✅ [12/12] Hoàn tất cài đặt!"

# Hiển thị thông tin
cat << 'INFO_EOF'

========================================
🎉 GHOST GENTOO - CÀI ĐẶT HOÀN TẤT!
========================================
THÔNG TIN HỆ THỐNG:
- Hostname: ghost-pc
- User: ghost (mật khẩu đã đặt)
- Timezone: Asia/Ho_Chi_Minh
- Locale: vi_VN.UTF-8
- Kernel: $(ls /lib/modules/)
- Window Manager: Hyprland

📋 LỆNH SAU KHI REBOOT:
1. Đăng nhập: ghost
2. Khởi động mạng: sudo rc-service NetworkManager start
3. Cấu hình WiFi: sudo nmtui
4. Khởi động Hyprland: Hyprland

🔧 CÔNG CỤ ĐÃ CÀI:
- Terminal: Kitty
- App Launcher: Wofi
- Status Bar: Waybar
- Editor: Neovim
- Network: NetworkManager + iwd

========================================
INFO_EOF

# Lưu thông tin cài đặt
cat > /root/install-info.txt << EOF
GHOST 2025 - GENTOO INSTALLATION
===============================
Installation Date: $(date)
User: $TARGET_USER
Hostname: $HOSTNAME
Timezone: $TIMEZONE
Locale: $LOCALE
Kernel: $(ls /lib/modules/)
Firmware: 20250808 (fixed)
Install Method: Direct from Gentoo Git
EOF

echo "📄 Thông tin cài đặt đã lưu tại: /root/install-info.txt"
CHROOT_EOF

# ==============================================================================
# PHẦN 6: CHẠY SCRIPT CHROOT
# ==============================================================================
echo "🚀 5. Chạy cài đặt trong chroot..."
chmod +x $WORKDIR/install-inside.sh
chroot $WORKDIR /bin/bash /install-inside.sh

# ==============================================================================
# PHẦN 7: HOÀN TẤT
# ==============================================================================
echo "✨ 6. Hoàn tất cài đặt!"

# Xóa script trong chroot
rm -f $WORKDIR/install-inside.sh

cat << 'COMPLETE_EOF'

==================================================
✅ GHOST 2025 - GENTOO INSTALLER - HOÀN TẤT!
==================================================

📋 THỰC HIỆN CÁC BƯỚC CUỐI CÙNG:

1. exit                           # Thoát khỏi chroot
2. umount -R /mnt/gentoo          # Unmount tất cả
3. reboot                         # Khởi động lại

==================================================
🚀 HỆ THỐNG ĐÃ SẴN SÀNG!

Sau khi reboot:
- Đăng nhập với user: ghost
- Mật khẩu: (mật khẩu bạn đã đặt)
- Để khởi động Hyprland: Hyprland

📞 HỖ TRỢ:
- GitHub: https://github.com/[your-username]/gentoo-ghost-installer
- Issues: Báo lỗi và góp ý

==================================================
COMPLETE_EOF

# Lưu thông tin ra ngoài chroot
cp $WORKDIR/root/install-info.txt /tmp/ghost-install-info.txt 2>/dev/null || true
echo "📄 Thông tin cài đặt cũng đã lưu tại: /tmp/ghost-install-info.txt"
