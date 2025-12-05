#!/bin/bash
# ========================================
# FIX DÙNG GENTOO GIT TRỰC TIẾP
# ========================================

set -e

# 1. CẤU HÌNH PORTAGE ĐƠN GIẢN
echo "Cấu hình Portage đơn giản..."
cat > /etc/portage/make.conf << 'EOF'
MAKEOPTS="-j1"
FEATURES="-sandbox -usersandbox"
EMERGE_DEFAULT_OPTS="--jobs=1 --with-bdeps=n"
USE="minimal"
ACCEPT_LICENSE="*"
EOF

# 2. TẢI VÀ CÀI KERNEL BẰNG TAY TỪ GIT GENTOO
echo "Tải kernel sources từ git gentoo..."
cd /usr/src
wget -q https://gitweb.gentoo.org/repo/gentoo.git/plain/sys-kernel/gentoo-sources/gentoo-sources-6.11.5.ebuild
ebuild gentoo-sources-6.11.5.ebuild manifest
ebuild gentoo-sources-6.11.5.ebuild unpack

# Tạo symlink
ln -sf /usr/src/linux-* /usr/src/linux || ln -sf /usr/src/linux-6.* /usr/src/linux

# 3. TẢI FIRMWARE TRỰC TIẾP
echo "Tải firmware từ kernel.org..."
cd /lib
mkdir -p firmware
cd firmware

# Tải firmware ổn định từ kernel.org (bản gốc)
wget -q https://mirrors.edge.kernel.org/pub/linux/kernel/firmware/linux-firmware-20250808.tar.xz
tar xf linux-firmware-20250808.tar.xz --strip-components=1
rm linux-firmware-20250808.tar.xz

# 4. COMPILE KERNEL ĐƠN GIẢN
echo "Compile kernel minimal..."
cd /usr/src/linux

# Dùng config mặc định
make defconfig

# Chỉ bật options tối thiểu
./scripts/config --disable DEBUG_INFO
./scripts/config --set-val CONFIG_MODULES y
./scripts/config --set-val CONFIG_BLK_DEV_INITRD y

make -j1
make modules_install
make install

# 5. CÀI CÁC GÓI CƠ BẢN TỪ GIT
echo "Cài packages cơ bản..."

# Tạo overlay tạm
mkdir -p /var/db/repos/local/{metadata,profiles}
echo "local" > /var/db/repos/local/profiles/repo_name
cat > /var/db/repos/local/metadata/layout.conf << 'EOF'
masters = gentoo
thin-manifests = true
EOF

# 6. CÀI GRUB ĐƠN GIẢN
echo "Cài GRUB..."
cat > /tmp/grub.ebuild << 'EOF'
EAPI=8
inherit toolchain-funcs
DESCRIPTION="GRUB Bootloader"
SRC_URI="https://ftp.gnu.org/gnu/grub/grub-2.12.tar.xz"
SLOT="0"
EOF

cd /tmp
wget https://ftp.gnu.org/gnu/grub/grub-2.12.tar.xz
tar xf grub-2.12.tar.xz
cd grub-2.12
./configure --prefix=/usr
make -j1
make install

# 7. CÀI ĐẶT GRUB
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# 8. CẤU HÌNH HỆ THỐNG
echo "Cấu hình cơ bản..."
echo "ghost-pc" > /etc/hostname
cat > /etc/fstab << 'EOF'
/dev/sda1    /    ext4    defaults    1 1
/dev/sda2    /home    ext4    defaults    0 2
EOF

# 9. TẠO USER
useradd -m -G wheel ghost
echo "Nhập mật khẩu cho ghost:"
passwd ghost

echo "========================================"
echo "FIX HOÀN TẤT!"
echo "Thoát chroot và reboot:"
echo "exit"
echo "umount -R /mnt/gentoo"
echo "reboot"
