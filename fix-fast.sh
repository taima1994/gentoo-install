#!/bin/bash
# ==============================================================================
# GHOST GENTOO - FIX & INSTALL COMPLETE (ONE SCRIPT)
# Chạy trong chroot (live~#) - KHÔNG cần sudo
# ==============================================================================

set -e

echo "🔥 BẮT ĐẦU FIX TOÀN BỘ HỆ THỐNG"

# ========== PHẦN 0: THIẾT LẬP MÔI TRƯỜNG ==========
echo "0. Thiết lập môi trường..."

# Fix PATH
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin"

# Mount các thư mục cần thiết (nếu chưa mount)
mount -t proc proc /proc 2>/dev/null || true
mount -t sysfs sysfs /sys 2>/dev/null || true
mount -o bind /dev /dev 2>/dev/null || true

# ========== PHẦN 1: KIỂM TRA VÀ CÀI GCC ==========
echo "1. Kiểm tra và cài GCC..."

if ! command -v gcc &> /dev/null; then
    echo "  → GCC không có, tải binary GCC từ stage3..."
    
    # Tìm GCC binary trong stage3
    if [ -f "/mnt/gentoo/stage3-*.tar.xz" ]; then
        tar -xf /mnt/gentoo/stage3-*.tar.xz usr/bin/gcc usr/bin/g++ usr/lib64/gcc -C / 2>/dev/null || true
    fi
    
    # Tải GCC binary từ mirror nếu cần
    if ! command -v gcc &> /dev/null; then
        echo "  → Tải GCC binary..."
        cd /tmp
        wget -q https://mirror.meowsmp.net/gentoo/releases/amd64/autobuilds/current-stage3-amd64-hardened-selinux-openrc/stage3-amd64-hardened-selinux-openrc-20251130T164554Z.tar.xz
        tar -xf stage3-*.tar.xz usr/bin/gcc usr/bin/g++ usr/lib64/gcc -C / 2>/dev/null || true
        rm -f stage3-*.tar.xz
    fi
fi

# ========== PHẦN 2: KIỂM TRA VÀ CÀI MAKE ==========
echo "2. Kiểm tra và cài MAKE..."

if ! command -v make &> /dev/null; then
    echo "  → MAKE không có, dùng busybox make..."
    # Dùng busybox make nếu có
    if command -v busybox &> /dev/null; then
        busybox ln -sf /bin/busybox /usr/bin/make
    else
        # Tải make binary
        cd /tmp
        wget -q https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz
        tar xzf make-4.4.1.tar.gz
        cd make-4.4.1
        # Dùng gcc có sẵn để compile make
        ./configure --prefix=/usr
        make -j1
        make install
    fi
fi

# ========== PHẦN 3: CẤU HÌNH PORTAGE ==========
echo "3. Cấu hình Portage..."

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

# Cấu hình repo đơn giản
cat > /etc/portage/repos.conf/gentoo.conf << 'EOF'
[gentoo]
location = /var/db/repos/gentoo
EOF

# ========== PHẦN 4: CÀI KERNEL BINARY ==========
echo "4. Cài kernel binary..."

cd /boot
# Copy kernel từ stage3 đã có
if [ ! -f "/boot/vmlinuz" ]; then
    echo "  → Copy kernel từ stage3..."
    cp /mnt/gentoo/boot/vmlinuz-* /boot/vmlinuz 2>/dev/null || \
    cp /boot/vmlinuz-* /boot/vmlinuz 2>/dev/null || \
    echo "  → Tải kernel mới..."
    wget -q https://mirror.meowsmp.net/gentoo/releases/amd64/autobuilds/current-stage3-amd64-hardened-selinux-openrc/stage3-amd64-hardened-selinux-openrc-20251130T164554Z.tar.xz
    tar xf stage3-*.tar.xz ./boot/vmlinuz-* --strip-components=2
    mv vmlinuz-* vmlinuz 2>/dev/null || true
    rm -f stage3-*.tar.xz
fi

# ========== PHẦN 5: CÀI FIRMWARE ==========
echo "5. Cài firmware..."

mkdir -p /lib/firmware
cd /lib/firmware
if [ ! -f "/lib/firmware/amd-ucode.img" ]; then
    wget -q https://mirrors.edge.kernel.org/pub/linux/kernel/firmware/linux-firmware-20250808.tar.xz
    tar xf linux-firmware-20250808.tar.xz --strip-components=1
    rm -f linux-firmware-20250808.tar.xz
fi

# ========== PHẦN 6: CÀI GRUB ==========
echo "6. Cài GRUB..."

# Tải và cài GRUB binary
cd /tmp
if ! command -v grub-install &> /dev/null; then
    wget -q https://ftp.gnu.org/gnu/grub/grub-2.12.tar.xz
    tar xf grub-2.12.tar.xz
    cd grub-2.12
    ./configure --prefix=/usr --disable-werror
    make -j1
    make install
fi

# Cài đặt GRUB
grub-install /dev/sda

# Tạo GRUB config đơn giản
cat > /boot/grub/grub.cfg << 'EOF'
set timeout=3
set default=0

menuentry "Ghost Gentoo" {
    insmod ext2
    set root=(hd0,1)
    linux /boot/vmlinuz root=/dev/sda1 ro quiet
}
EOF

# ========== PHẦN 7: CẤU HÌNH HỆ THỐNG ==========
echo "7. Cấu hình hệ thống..."

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

# Timezone
echo "Asia/Ho_Chi_Minh" > /etc/timezone

# ========== PHẦN 8: TẠO USER ==========
echo "8. Tạo user..."

if ! id "ghost" &>/dev/null; then
    useradd -m -G wheel,audio,video ghost
    echo "🔐 NHẬP MẬT KHẨU CHO USER 'ghost':"
    passwd ghost
fi

# SUDO
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/10-wheel
chmod 440 /etc/sudoers.d/10-wheel

# ========== PHẦN 9: CÀI NETWORK ==========
echo "9. Cài network..."

# Dùng dhcpcd đơn giản
cd /tmp
if ! command -v dhcpcd &> /dev/null; then
    wget -q https://www.infradead.org/~tgr/dhcpcd/dhcpcd-10.0.2.tar.gz
    tar xzf dhcpcd-10.0.2.tar.gz
    cd dhcpcd-10.0.2
    ./configure --prefix=/usr
    make -j1
    make install
fi

# ========== PHẦN 10: HOÀN TẤT ==========
echo "✅ HOÀN TẤT!"

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

🔧 HỆ THỐNG ĐÃ CÀI:
- Kernel: Binary
- Firmware: 20250808
- Bootloader: GRUB
- Network: dhcpcd
- User: ghost (sudo enabled)

========================================
EOF

# Lưu thông tin
cat > /root/install-info.txt << EOF
GHOST GENTOO - INSTALLATION COMPLETE
====================================
Installation Date: $(date)
User: ghost
Hostname: ghost-pc
Timezone: Asia/Ho_Chi_Minh
====================================
EOF