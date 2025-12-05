#!/bin/bash
# ========================================
# FIX PORTAGE & CÀI ĐẶT TỐI THIỂU
# Chạy trong chroot (live~#)
# ========================================

set -e

echo "🚀 BẮT ĐẦU FIX PORTAGE VÀ CÀI ĐẶT CƠ BẢN"

# 1. KIỂM TRA VÀ SỬA CẤU TRÚC THƯ MỤC
echo "1. Kiểm tra cấu trúc thư mục..."
mkdir -p /etc/portage/repos.conf
mkdir -p /var/db/repos/gentoo

# 2. TẢI LẠI PORTAGE TREE TỪ ĐẦU
echo "2. Tải lại Portage tree..."
cd /var/db/repos/gentoo
rm -rf *
wget -q --show-progress https://mirror.meowsmp.net/gentoo/snapshots/portage-latest.tar.xz
tar xpf portage-latest.tar.xz --strip-components=1
rm -f portage-latest.tar.xz

# 3. CẤU HÌNH REPOSITORY
echo "3. Cấu hình repository..."
cat > /etc/portage/repos.conf/gentoo.conf << 'EOF'
[gentoo]
location = /var/db/repos/gentoo
sync-type = rsync
sync-uri = rsync://rsync.gentoo.org/gentoo-portage
auto-sync = yes
EOF

# 4. CHỌN PROFILE ĐƠN GIẢN
echo "4. Chọn profile..."
# Dùng profile tối thiểu nhất
if [ -f "/var/db/repos/gentoo/profiles/default/linux/amd64/17.1/desktop" ]; then
    ln -sf /var/db/repos/gentoo/profiles/default/linux/amd64/17.1/desktop /etc/portage/make.profile
else
    # Chọn profile đầu tiên có sẵn
    FIRST_PROFILE=$(find /var/db/repos/gentoo/profiles -name "make.default" | head -1)
    if [ -n "$FIRST_PROFILE" ]; then
        PROFILE_DIR=$(dirname "$FIRST_PROFILE")
        ln -sf "$PROFILE_DIR" /etc/portage/make.profile
    fi
fi

# 5. CÀI PORTAGE BẰNG TAY
echo "5. Cài đặt Portage bằng tay..."
cd /tmp
wget -q https://mirror.meowsmp.net/gentoo/distfiles/portage-3.0.72.tar.xz
tar xf portage-3.0.72.tar.xz
cd portage-3.0.72
python3 setup.py install --system --no-prefix

# 6. CÀI CÁC GÓI CƠ BẢN BẰNG TAY
echo "6. Cài các gói cơ bản..."

# Tải và cài make
cd /tmp
wget -q https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz
tar xzf make-4.4.1.tar.gz
cd make-4.4.1
./configure --prefix=/usr
make -j1
make install

# Tải và cài bash
cd /tmp
wget -q https://ftp.gnu.org/gnu/bash/bash-5.2.tar.gz
tar xzf bash-5.2.tar.gz
cd bash-5.2
./configure --prefix=/usr
make -j1
make install

# 7. CÀI KERNEL BINARY (KHÔNG CẦN COMPILE)
echo "7. Cài kernel binary..."
mkdir -p /etc/portage/package.accept_keywords
echo "sys-kernel/gentoo-kernel-bin ~amd64" > /etc/portage/package.accept_keywords/kernel-bin

emerge --oneshot --nodeps sys-kernel/gentoo-kernel-bin 2>/dev/null || \
echo "⚠️  Không thể emerge kernel, tải binary trực tiếp..."

# Tải kernel binary nếu emerge lỗi
if [ ! -f "/boot/vmlinuz" ]; then
    cd /boot
    wget -q https://mirror.meowsmp.net/gentoo/releases/amd64/autobuilds/current-stage3-amd64-hardened-selinux-openrc/stage3-amd64-hardened-selinux-openrc-20251130T164554Z.tar.xz
    tar xf stage3-*.tar.xz ./boot/vmlinuz-* --strip-components=2
    mv vmlinuz-* vmlinuz
fi

# 8. CÀI FIRMWARE BẰNG TAY
echo "8. Cài firmware..."
cd /lib
mkdir -p firmware
cd firmware
wget -q https://mirrors.edge.kernel.org/pub/linux/kernel/firmware/linux-firmware-20250808.tar.xz
tar xf linux-firmware-20250808.tar.xz --strip-components=1
rm linux-firmware-20250808.tar.xz

# 9. CÀI GRUB BẰNG TAY
echo "9. Cài GRUB..."
cd /tmp
wget -q https://ftp.gnu.org/gnu/grub/grub-2.12.tar.xz
tar xf grub-2.12.tar.xz
cd grub-2.12
./configure --prefix=/usr --disable-werror
make -j1
make install

grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# 10. CẤU HÌNH HỆ THỐNG CƠ BẢN
echo "10. Cấu hình hệ thống..."

# FSTAB
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

# Tạo user
echo "11. Tạo user..."
useradd -m -G wheel ghost
echo "🔐 NHẬP MẬT KHẨU CHO USER 'ghost':"
passwd ghost

# Cấu hình sudo
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/10-wheel
chmod 440 /etc/sudoers.d/10-wheel

# 12. CÀI NETWORK CƠ BẢN
echo "12. Cài network cơ bản..."
cd /tmp
wget -q https://www.infradead.org/~tgr/dhcpcd/dhcpcd-10.0.2.tar.gz
tar xzf dhcpcd-10.0.2.tar.gz
cd dhcpcd-10.0.2
./configure --prefix=/usr
make -j1
make install

# 13. CẤU HÌNH DỊCH VỤ
echo "13. Cấu hình dịch vụ..."
rc-update add dhcpcd default

# 14. TẠO INITRAMFS ĐƠN GIẢN
echo "14. Tạo initramfs..."
cd /boot
mkinitramfs -o initramfs.img $(ls /lib/modules/)

echo "========================================"
echo "✅ FIX HOÀN TẤT!"
echo ""
echo "📋 LỆNH ĐỂ THOÁT VÀ REBOOT:"
echo "1. exit                          # Thoát chroot"
echo "2. umount -R /mnt/gentoo         # Unmount"
echo "3. reboot                        # Khởi động lại"
echo ""
echo "💡 SAU KHI BOOT:"
echo "- Đăng nhập với user: ghost"
echo "- Chạy lệnh: sudo dhcpcd eth0    # Để có mạng"
echo "- Cài thêm gói: sudo emerge [tên-gói]"
echo "========================================"