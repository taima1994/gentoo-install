#!/bin/bash
# ==============================================================================
# GHOST 2025 - GENTOO INSTALLER - HOÀN CHỈNH
# Sử dụng mirror meowsmp.net (đã kiểm tra hoạt động)
# ==============================================================================

set -euo pipefail
trap 'echo "[LỖI] Dừng tại dòng $LINENO" && exit 1' ERR

# ==============================================================================
# BIẾN CẤU HÌNH
# ==============================================================================
readonly WORKDIR="/mnt/gentoo"
readonly TARGET_USER="ghost"
readonly HOSTNAME="ghost-pc"
readonly TIMEZONE="Asia/Ho_Chi_Minh"
readonly LOCALE="vi_VN.UTF-8"

# URLs - Sử dụng mirror meowsmp.net như hiện tại
readonly STAGE3_URL="https://mirror.meowsmp.net/gentoo/releases/amd64/autobuilds/current-stage3-amd64-hardened-selinux-openrc/stage3-amd64-hardened-selinux-openrc-20251130T164554Z.tar.xz"
readonly PORTAGE_URL="https://mirror.meowsmp.net/gentoo/snapshots/portage-latest.tar.xz"

# ==============================================================================
# HÀM HIỂN THỊ
# ==============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

show_step() { echo -e "\n${GREEN}[+]${NC} $1"; }
show_info() { echo -e "${YELLOW}[*]${NC} $1"; }
show_error() { echo -e "${RED}[!]${NC} $1"; }

# ==============================================================================
# BẮT ĐẦU CÀI ĐẶT
# ==============================================================================
clear
echo "================================================"
echo "GHOST 2025 - GENTOO INSTALLER"
echo "Mirror: meowsmp.net"
echo "================================================"

# Kiểm tra quyền root
if [[ $EUID -ne 0 ]]; then
    show_error "Cần chạy với quyền root: sudo bash $0"
    exit 1
fi

# Cảnh báo
show_info "CẢNH BÁO: Toàn bộ dữ liệu trên /dev/sda và /dev/sdb sẽ bị xóa!"
read -p "Tiếp tục? (yes/NO): " confirm
if [[ "${confirm,,}" != "yes" ]]; then
    show_error "Đã hủy cài đặt"
    exit 0
fi

# ==============================================================================
# PHẦN 1: PHÂN VÙNG
# ==============================================================================
show_step "1. Phân vùng đĩa..."

# Xóa partition table cũ (nếu có)
wipefs -a /dev/sda 2>/dev/null || true
wipefs -a /dev/sdb 2>/dev/null || true

# Tạo partition table và phân vùng
parted -s /dev/sda mklabel gpt
parted -s /dev/sda mkpart primary 1MiB 200GiB
parted -s /dev/sda set 1 boot on
parted -s /dev/sda mkpart primary 200GiB 100%

parted -s /dev/sdb mklabel gpt
parted -s /dev/sdb mkpart primary 1MiB 100%

# ==============================================================================
# PHẦN 2: ĐỊNH DẠNG VÀ MOUNT
# ==============================================================================
show_step "2. Định dạng và mount..."

# Định dạng filesystem
mkfs.ext4 -F -L "GENTOO_ROOT" /dev/sda1
mkfs.ext4 -F -L "GENTOO_HOME" /dev/sda2
mkfs.ext4 -F -L "GENTOO_PORTAGE" /dev/sdb1

# Mount hệ thống
mount /dev/sda1 $WORKDIR
mkdir -p $WORKDIR/{boot,home,var/tmp/portage}
mount /dev/sda2 $WORKDIR/home
mount /dev/sdb1 $WORKDIR/var/tmp/portage

# ==============================================================================
# PHẦN 3: TẢI VÀ GIẢI NÉN STAGE3
# ==============================================================================
show_step "3. Tải Stage3 và Portage..."
cd $WORKDIR

# Tải stage3
show_info "Đang tải stage3..."
wget -q --show-progress -O stage3.tar.xz "$STAGE3_URL"

# Tải portage snapshot
show_info "Đang tải portage snapshot..."
wget -q --show-progress -O portage.tar.xz "$PORTAGE_URL"

# Giải nén
show_info "Giải nén stage3..."
tar xpf stage3.tar.xz --xattrs-include='*.*' --numeric-owner

show_info "Giải nén portage..."
tar xpf portage.tar.xz -C usr

# Xóa file tải về để tiết kiệm dung lượng
rm -f stage3.tar.xz portage.tar.xz

# ==============================================================================
# PHẦN 4: CHUẨN BỊ CHROOT
# ==============================================================================
show_step "4. Chuẩn bị môi trường chroot..."

# Mount các filesystem cần thiết
mount --types proc /proc $WORKDIR/proc
mount --rbind /sys $WORKDIR/sys
mount --make-rslave $WORKDIR/sys
mount --rbind /dev $WORKDIR/dev
mount --make-rslave $WORKDIR/dev
cp -L /etc/resolv.conf $WORKDIR/etc/

# ==============================================================================
# PHẦN 5: SCRIPT CHROOT - HOÀN CHỈNH
# ==============================================================================
cat > $WORKDIR/install-inside.sh << 'CHROOT_EOF'
#!/bin/bash
set -euo pipefail

echo "========================================"
echo "BẮT ĐẦU CÀI ĐẶT BÊN TRONG CHROOT"
echo "========================================"

# Biến trong chroot
TARGET_USER="ghost"
HOSTNAME="ghost-pc"
TIMEZONE="Asia/Ho_Chi_Minh"
LOCALE="vi_VN.UTF-8"

# 5.1: Cấu hình cơ bản
echo "[1] Cấu hình cơ bản..."

# Tạo fstab
cat > /etc/fstab << FSTAB_EOF
# <fs>                  <mountpoint>    <type>    <opts>              <dump/pass>
/dev/sda1               /               ext4      noatime,errors=remount-ro 0 1
/dev/sda2               /home           ext4      defaults,noatime    0 2
/dev/sdb1               /var/tmp/portage ext4     defaults,noatime    0 2
FSTAB_EOF

# Hostname
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts << HOSTS_EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS_EOF

# 5.2: Cấu hình Portage
echo "[2] Cấu hình Portage..."

# Cập nhật Portage
emerge-webrsync

# Cấu hình make.conf
cat >> /etc/portage/make.conf << MAKE_CONF_EOF
# Cấu hình từ GHOST Installer
MAKEOPTS="-j\$(nproc)"
EMERGE_DEFAULT_OPTS="--jobs=\$(nproc) --load-average=\$(nproc)"
USE="hardened selinux X wayland pulseaudio dbus elogind networkmanager"
VIDEO_CARDS="amdgpu radeonsi"
INPUT_DEVICES="libinput"
GRUB_PLATFORMS="efi-64"
FEATURES="parallel-fetch parallel-install"
MAKE_CONF_EOF

# 5.3: Cập nhật hệ thống
echo "[3] Cập nhật @world..."
emerge --update --deep --newuse @world

# 5.4: Cài đặt kernel
echo "[4] Cài đặt kernel..."
emerge sys-kernel/gentoo-sources sys-kernel/genkernel sys-kernel/linux-firmware

# Sử dụng genkernel để đơn giản
cd /usr/src/linux
genkernel --kernel-config=/usr/src/linux/.config all

# 5.5: Cấu hình hệ thống
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

# 5.6: Tạo người dùng
echo "[6] Tạo người dùng..."
useradd -m -G wheel,audio,video,portage,usb,cdrom $TARGET_USER
echo "Đặt mật khẩu cho user '$TARGET_USER':"
passwd $TARGET_USER

# Cấu hình sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers.d/10-wheel
chmod 440 /etc/sudoers.d/10-wheel

# 5.7: Cài đặt GRUB
echo "[7] Cài đặt GRUB..."
emerge sys-boot/grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# 5.8: Cài đặt môi trường đồ họa
echo "[8] Cài đặt Hyprland và ứng dụng..."

# Cài các gói cần thiết
emerge gui-wm/hyprland \
       x11-terms/kitty \
       gui-apps/waybar \
       gui-apps/wofi \
       x11-misc/xdg-user-dirs \
       media-sound/pulseaudio \
       media-video/pipewire

# Cài đặt ứng dụng hữu ích
emerge app-editors/neovim \
       sys-process/htop \
       net-misc/networkmanager \
       net-wireless/iwd \
       sys-auth/elogind \
       sys-apps/dbus

# 5.9: Cấu hình dịch vụ
echo "[9] Cấu hình dịch vụ..."
rc-update add NetworkManager default
rc-update add dbus default
rc-update add elogind default
rc-update add sshd default

# 5.10: Cài đặt thêm công cụ hệ thống
echo "[10] Cài đặt công cụ hệ thống..."
emerge sys-apps/pciutils \
       sys-apps/usbutils \
       sys-power/acpid \
       net-misc/dhcpcd \
       net-misc/openssh

# 5.11: Tạo thư mục người dùng
echo "[11] Thiết lập thư mục người dùng..."
su - $TARGET_USER -c "xdg-user-dirs-update"

echo "========================================"
echo "CÀI ĐẶT HOÀN TẤT!"
echo "========================================"
echo "Thông tin hệ thống:"
echo "- Hostname: $HOSTNAME"
echo "- User: $TARGET_USER"
echo "- Timezone: $TIMEZONE"
echo "- Locale: $LOCALE"
echo ""
echo "Khởi động lại và đăng nhập với user '$TARGET_USER'"
CHROOT_EOF

# ==============================================================================
# PHẦN 6: CHẠY SCRIPT TRONG CHROOT
# ==============================================================================
show_step "5. Chạy cài đặt trong chroot..."
chmod +x $WORKDIR/install-inside.sh
chroot $WORKDIR /bin/bash /install-inside.sh

# ==============================================================================
# PHẦN 7: HOÀN TẤT
# ==============================================================================
show_step "6. Hoàn tất cài đặt!"

# Xóa script trong chroot
rm -f $WORKDIR/install-inside.sh

echo "================================================"
echo "GHOST 2025 - GENTOO INSTALLER - HOÀN TẤT"
echo "================================================"
echo ""
echo "THỰC HIỆN CÁC BƯỚC CUỐI CÙNG:"
echo "1. exit                           # Thoát khỏi chroot"
echo "2. umount -R /mnt/gentoo          # Unmount tất cả"
echo "3. reboot                         # Khởi động lại"
echo ""
echo "SAU KHI KHỞI ĐỘNG LẠI:"
echo "- Đăng nhập với user: ghost"
echo "- Cấu hình NetworkManager: sudo nmtui"
echo "- Cài đặt thêm ứng dụng: sudo emerge --ask [package]"
echo "================================================"

# Lưu thông tin cài đặt
cat > $WORKDIR/install-info.txt << EOF
GHOST 2025 - GENTOO INSTALLATION
===============================
Installation Date: $(date)
User: ghost
Hostname: ghost-pc
Timezone: Asia/Ho_Chi_Minh
Locale: vi_VN.UTF-8
Kernel: $(uname -r)
Mirror: meowsmp.net
EOF

show_info "Thông tin cài đặt đã lưu tại: $WORKDIR/install-info.txt"
