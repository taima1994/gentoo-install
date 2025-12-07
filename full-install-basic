#!/bin/bash
set -e
echo "GHOST 2025 - GENTOO INSTALLER (SIMPLE VERSION)"
echo "=============================================="

# Phần 1: Phân vùng đơn giản như Tecmint
echo "1. Phân vùng đơn giản..."
parted -s /dev/sda mklabel gpt
parted -s /dev/sda mkpart primary 1MiB 201MiB
parted -s /dev/sda set 1 boot on
parted -s /dev/sda mkpart primary 201MiB 100%

# Phần 2: Format và mount
echo "2. Format và mount..."
mkfs.fat -F 32 /dev/sda1
mkfs.ext4 /dev/sda2
mount /dev/sda2 /mnt/gentoo
mkdir /mnt/gentoo/boot
mount /dev/sda1 /mnt/gentoo/boot

# Phần 3: Tải stage3 (giữ nguyên mirror bạn dùng)
echo "3. Tải Stage3..."
cd /mnt/gentoo
wget -c https://mirror.meowsmp.net/gentoo/releases/amd64/autobuilds/current-stage3-amd64-hardened-selinux-openrc/stage3-amd64-hardened-selinux-openrc-20251130T164554Z.tar.xz
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

# Phần 4: Chroot và cài đặt đơn giản
echo "4. Vào chroot..."
mount -t proc proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
cp /etc/resolv.conf /mnt/gentoo/etc/

# Tạo script chroot đơn giản như Tecmint
cat > /mnt/gentoo/install-inside.sh << 'CHROOT_EOF'
#!/bin/bash
set -e
source /etc/profile

echo "========================================"
echo "GHOST GENTOO - SIMPLE INSTALL"
echo "========================================"

# 1. Cấu hình cơ bản
echo "1. Cấu hình cơ bản..."

# Chọn mirror gần
mkdir -p /etc/portage/repos.conf
cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf

# Cập nhật Portage
emerge-webrsync

# 2. Chọn profile đơn giản
echo "2. Chọn profile..."
eselect profile list
# Chọn profile 1 (default)
eselect profile set 1

# 3. Cập nhật @world (bước quan trọng)
echo "3. Cập nhật hệ thống..."
emerge --ask --verbose --update --deep --newuse @world

# 4. Cấu hình timezone và locale
echo "4. Cấu hình timezone và locale..."
echo "Asia/Ho_Chi_Minh" > /etc/timezone
emerge --config sys-libs/timezone-data

echo "vi_VN.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set vi_VN.utf8
env-update && source /etc/profile

# 5. Cài kernel đơn giản (cách Tecmint)
echo "5. Cài kernel..."
emerge --ask sys-kernel/gentoo-sources
emerge --ask sys-kernel/genkernel

cd /usr/src/linux
cp /proc/config.gz /usr/src/linux/.config
make olddefconfig
genkernel --install all

# 6. Cấu hình hệ thống
echo "6. Cấu hình hệ thống..."

# FSTAB đơn giản
cat > /etc/fstab << 'EOF'
/dev/sda1   /boot   vfat    defaults    0 2
/dev/sda2   /       ext4    noatime     0 1
EOF

# Hostname
echo "ghost-pc" > /etc/hostname
cat > /etc/hosts << 'EOF'
127.0.0.1   localhost
127.0.1.1   ghost-pc.localdomain ghost-pc
EOF

# 7. Cài GRUB đơn giản
echo "7. Cài GRUB..."
emerge --ask sys-boot/grub
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# 8. Tạo user
echo "8. Tạo user..."
useradd -m -G wheel,audio,video ghost
echo "ghost:ghost" | chpasswd

# Cấu hình sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# 9. Cài NetworkManager
echo "9. Cài NetworkManager..."
emerge --ask net-misc/networkmanager
rc-update add NetworkManager default

# 10. Cài SSH
echo "10. Cài SSH..."
emerge --ask net-misc/openssh
rc-update add sshd default

# 11. Cài một số công cụ cơ bản
echo "11. Cài công cụ cơ bản..."
emerge --ask app-editors/neovim sys-process/htop

echo "========================================"
echo "✅ CÀI ĐẶT HOÀN TẤT!"
echo "========================================"
echo "User: ghost"
echo "Password: ghost"
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
