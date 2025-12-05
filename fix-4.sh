#!/bin/bash
# ========================================
# GHOST GENTOO - INSTALLER FINAL
# Chạy trong chroot (live~#)
# ========================================

set -e

echo "🔥 BẮT ĐẦU CÀI ĐẶT GHOST GENTOO"

# ========== PHẦN 1: FIX PORTAGE & CÀI CÔNG CỤ CƠ BẢN ==========
echo "1. Fix Portage và cài công cụ cơ bản..."

# Kiểm tra và tạo thư mục
mkdir -p /etc/portage/repos.conf
mkdir -p /var/db/repos/gentoo

# Tải Portage tree nếu chưa có
if [ ! -f "/var/db/repos/gentoo/profiles/repo_name" ]; then
    echo "  → Tải Portage tree..."
    cd /var/db/repos/gentoo
    wget -q https://mirror.meowsmp.net/gentoo/snapshots/portage-latest.tar.xz
    tar xpf portage-latest.tar.xz --strip-components=1
    rm -f portage-latest.tar.xz
fi

# Cấu hình repository
cat > /etc/portage/repos.conf/gentoo.conf << 'EOF'
[gentoo]
location = /var/db/repos/gentoo
sync-type = rsync
sync-uri = rsync://rsync.gentoo.org/gentoo-portage
EOF

# Cài MAKE bằng tay nếu cần
if ! command -v make &> /dev/null; then
    echo "  → Cài make bằng tay..."
    cd /tmp
    wget -q https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz
    tar xzf make-4.4.1.tar.gz
    cd make-4.4.1
    ./configure --prefix=/usr
    make -j1
    make install
fi

# ========== PHẦN 2: CÀI KERNEL ==========
echo "2. Cài kernel..."

# Tải kernel binary trực tiếp
cd /boot
echo "  → Tải kernel binary..."
wget -q https://mirror.meowsmp.net/gentoo/releases/amd64/autobuilds/current-stage3-amd64-hardened-selinux-openrc/stage3-amd64-hardened-selinux-openrc-20251130T164554Z.tar.xz
tar xf stage3-*.tar.xz ./boot/vmlinuz-* ./boot/System.map-* --strip-components=2
mv vmlinuz-* vmlinuz 2>/dev/null || true
rm -f stage3-*.tar.xz

# ========== PHẦN 3: CÀI FIRMWARE ==========
echo "3. Cài firmware..."

cd /lib
mkdir -p firmware
cd firmware
wget -q https://mirrors.edge.kernel.org/pub/linux/kernel/firmware/linux-firmware-20250808.tar.xz
tar xf linux-firmware-20250808.tar.xz --strip-components=1
rm linux-firmware-20250808.tar.xz

# ========== PHẦN 4: CÀI GRUB ==========
echo "4. Cài GRUB..."

cd /tmp
wget -q https://ftp.gnu.org/gnu/grub/grub-2.12.tar.xz
tar xf grub-2.12.tar.xz
cd grub-2.12
./configure --prefix=/usr --disable-werror
make -j1
make install

# Cài đặt GRUB vào MBR
grub-install /dev/sda

# Tạo file cấu hình GRUB đơn giản
cat > /boot/grub/grub.cfg << 'EOF'
set timeout=5
set default=0

menuentry "Ghost Gentoo" {
    insmod ext2
    set root=(hd0,1)
    linux /boot/vmlinuz root=/dev/sda1 ro quiet
}
EOF

# ========== PHẦN 5: CẤU HÌNH HỆ THỐNG ==========
echo "5. Cấu hình hệ thống..."

# FSTAB
cat > /etc/fstab << 'EOF'
/dev/sda1    /               ext4    defaults,noatime    0 1
/dev/sda2    /home           ext4    defaults,noatime    0 2
/dev/sdb1    /var/tmp/portage ext4  defaults,noatime    0 2
EOF

# HOSTNAME
echo "ghost-pc" > /etc/hostname
cat > /etc/hosts << 'EOF'
127.0.0.1   localhost
::1         localhost
127.0.1.1   ghost-pc.localdomain ghost-pc
EOF

# TIMEZONE
echo "Asia/Ho_Chi_Minh" > /etc/timezone

# ========== PHẦN 6: TẠO USER ==========
echo "6. Tạo user..."

useradd -m -G wheel,audio,video ghost
echo "🔐 NHẬP MẬT KHẨU CHO USER 'ghost':"
passwd ghost

# SUDO
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/10-wheel
chmod 440 /etc/sudoers.d/10-wheel

# ========== PHẦN 7: CÀI NETWORK CƠ BẢN ==========
echo "7. Cài network cơ bản..."

cd /tmp
wget -q https://www.infradead.org/~tgr/dhcpcd/dhcpcd-10.0.2.tar.gz
tar xzf dhcpcd-10.0.2.tar.gz
cd dhcpcd-10.0.2
./configure --prefix=/usr
make -j1
make install

# ========== PHẦN 8: CÀI CÔNG CỤ CƠ BẢN ==========
echo "8. Cài công cụ cơ bản..."

# Cài bash nếu cần
if [ ! -f "/bin/bash" ]; then
    cd /tmp
    wget -q https://ftp.gnu.org/gnu/bash/bash-5.2.tar.gz
    tar xzf bash-5.2.tar.gz
    cd bash-5.2
    ./configure --prefix=/usr
    make -j1
    make install
fi

# ========== PHẦN 9: CẤU HÌNH DỊCH VỤ ==========
echo "9. Cấu hình dịch vụ..."

rc-update add dhcpcd default

# ========== PHẦN 10: TẠO INITRAMFS ==========
echo "10. Tạo initramfs..."

cd /boot
mkinitramfs -o initramfs.img $(ls /lib/modules/ 2>/dev/null | head -1) 2>/dev/null || true

# ========== PHẦN 11: HOÀN TẤT ==========
echo "✅ HOÀN TẤT CÀI ĐẶT!"

cat << 'EOF'

========================================
🎉 GHOST GENTOO - CÀI ĐẶT THÀNH CÔNG!
========================================

📋 LỆNH ĐỂ THOÁT VÀ REBOOT:
1. exit                          # Thoát chroot
2. umount -R /mnt/gentoo         # Unmount
3. reboot                        # Khởi động lại

💡 SAU KHI BOOT:
- Đăng nhập với user: ghost
- Mật khẩu: (mật khẩu bạn vừa đặt)
- Để có mạng: sudo dhcpcd eth0
- Để cài thêm gói: sudo emerge [tên-gói]

🔧 HỆ THỐNG ĐÃ CÀI:
- Kernel: Binary từ stage3
- Firmware: 20250808
- Bootloader: GRUB 2.12
- Network: dhcpcd
- User: ghost (sudo enabled)

========================================
EOF

# Lưu thông tin cài đặt
cat > /root/install-info.txt << EOF
GHOST GENTOO - INSTALLATION COMPLETE
====================================
Installation Date: $(date)
User: ghost
Hostname: ghost-pc
Timezone: Asia/Ho_Chi_Minh
Kernel: $(ls /boot/vmlinuz* 2>/dev/null || echo "binary")
Firmware: 20250808
Boot Method: BIOS/MBR
Network: dhcpcd
====================================
EOF