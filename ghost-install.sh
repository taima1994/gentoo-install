#!/bin/bash
set -e
echo "GHOST 2025 - GENTOO INSTALLER"
echo "=============================="

# Phần 1: Phân vùng
echo "1. Phân vùng..."
parted -s /dev/sda mklabel gpt
parted -s /dev/sda mkpart primary 1MiB 200GiB
parted -s /dev/sda mkpart primary 200GiB 100%
parted -s /dev/sdb mklabel gpt
parted -s /dev/sdb mkpart primary 1MiB 100%

# Phần 2: Format và mount
echo "2. Format và mount..."
mkfs.ext4 -F /dev/sda1
mkfs.ext4 -F /dev/sda2
mkfs.ext4 -F /dev/sdb1
mount /dev/sda1 /mnt/gentoo
mkdir -p /mnt/gentoo/{home,var/tmp/portage}
mount /dev/sda2 /mnt/gentoo/home
mount /dev/sdb1 /mnt/gentoo/var/tmp/portage

# Phần 3: Tải stage3
echo "3. Tải Stage3..."
cd /mnt/gentoo
wget -c https://mirror.meowsmp.net/gentoo/releases/amd64/autobuilds/current-stage3-amd64-hardened-selinux-openrc/stage3-amd64-hardened-selinux-openrc-20251130T164554Z.tar.xz
wget -c https://mirror.meowsmp.net/gentoo/snapshots/portage-latest.tar.xz
tar xpf stage3-*.tar.xz --xattrs-include="*.*" --numeric-owner
tar xpf portage-latest.tar.xz -C usr

# Phần 4: Chroot và cài đặt
echo "4. Vào chroot..."
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
cp -L /etc/resolv.conf /mnt/gentoo/etc/

# Tạo script chroot - ĐÃ FIX TẤT CẢ LỖI
cat > /mnt/gentoo/install-inside.sh << 'CHROOT_EOF'
#!/bin/bash
set -e
source /etc/profile

echo "========================================"
echo "GHOST 2025 - CÀI ĐẶT TRONG CHROOT"
echo "========================================"

# ========== FIX 1: KIỂM TRA VÀ CẤU HÌNH MÔI TRƯỜNG ==========
echo "1. Kiểm tra môi trường..."
export PATH="/usr/bin:/bin:/usr/sbin:/sbin"
mkdir -p /etc/portage/package.{use,unmask,license}

# ========== FIX 2: CẤU HÌNH MAKE.CONF ĐÚNG ==========
echo "2. Cấu hình Portage..."
emerge-webrsync

# Cấu hình make.conf đơn giản, không lỗi
cat > /etc/portage/make.conf << 'EOF'
MAKEOPTS="-j2"
EMERGE_DEFAULT_OPTS="--jobs=2"
USE="hardened selinux X wayland pulseaudio dbus elogind networkmanager"
VIDEO_CARDS="amdgpu radeonsi"
INPUT_DEVICES="libinput"
GRUB_PLATFORMS="efi-64"
FEATURES="parallel-fetch"
ACCEPT_LICENSE="*"
EOF

# ========== FIX 3: XỬ LÝ LỖI FIRMWARE ==========
echo "3. Xử lý firmware..."
echo "sys-kernel/linux-firmware linux-fw-redistributable" > /etc/portage/package.license/linux-firmware
echo "=sys-kernel/linux-firmware-20250808" > /etc/portage/package.unmask/linux-firmware

# ========== FIX 4: XỬ LÝ LỖI GETTEXT OPENMP ==========
echo "sys-devel/gettext -openmp" > /etc/portage/package.use/gettext

# ========== BẮT ĐẦU CÀI ĐẶT ==========
echo "4. Cập nhật hệ thống..."
emerge --update --deep --newuse @world

# ========== FIX 5: CÀI KERNEL ĐƠN GIẢN ==========
echo "5. Cài đặt kernel..."
emerge sys-kernel/gentoo-sources sys-kernel/genkernel

# Tạo symlink kernel
eselect kernel set 1
cd /usr/src/linux

# Dùng genkernel để tránh lỗi
genkernel --kernel-config=/usr/src/linux/.config all

# ========== FIX 6: CÀI FIRMWARE SAU KERNEL ==========
echo "6. Cài firmware..."
emerge =sys-kernel/linux-firmware-20250808

# ========== FIX 7: CẤU HÌNH FSTAB ==========
echo "7. Cấu hình hệ thống..."
cat > /etc/fstab << 'EOF'
/dev/sda1    /               ext4    noatime,errors=remount-ro    0 1
/dev/sda2    /home           ext4    defaults,noatime             0 2
/dev/sdb1    /var/tmp/portage ext4  defaults,noatime              0 2
EOF

# Hostname
echo "ghost-pc" > /etc/hostname
cat > /etc/hosts << 'EOF'
127.0.0.1   localhost
::1         localhost
127.0.1.1   ghost-pc.localdomain ghost-pc
EOF

# Timezone và locale
echo "Asia/Ho_Chi_Minh" > /etc/timezone
emerge --config sys-libs/timezone-data
echo "vi_VN.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set vi_VN.utf8
env-update && source /etc/profile

# ========== FIX 8: CÀI GRUB ĐÚNG ==========
echo "8. Cài đặt GRUB..."
emerge sys-boot/grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# ========== TẠO NGƯỜI DÙNG ==========
echo "9. Tạo người dùng..."
useradd -m -G wheel,audio,video,portage ghost
echo "ghost:ghost" | chpasswd

# Cấu hình sudo
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel

# ========== FIX 9: CÀI HYPRLAND ĐÚNG ==========
echo "10. Cài đặt Hyprland..."

# Cấu hình USE flags cho Hyprland
cat >> /etc/portage/package.use/hyprland << 'EOF'
gui-wm/hyprland -systemd
x11-terms/kitty -wayland
EOF

# Cài đặt
emerge gui-wm/hyprland x11-terms/kitty waybar wofi

# ========== CÀI CÔNG CỤ HỆ THỐNG ==========
echo "11. Cài công cụ hệ thống..."
emerge sys-apps/catalyst
emerge net-misc/networkmanager sys-auth/elogind app-editors/neovim

# ========== CẤU HÌNH DỊCH VỤ ==========
echo "12. Cấu hình dịch vụ..."
rc-update add sshd default
rc-update add NetworkManager default
rc-update add elogind default

# ========== HOÀN TẤT ==========
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
echo "reboot"
