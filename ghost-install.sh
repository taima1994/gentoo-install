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

# Tạo script chroot
cat > /mnt/gentoo/install-inside.sh << 'CHROOT_EOF'
#!/bin/bash
set -e
source /etc/profile

# Cài đặt
emerge-webrsync
echo 'MAKEOPTS="-j$(nproc)"' >> /etc/portage/make.conf
echo 'USE="hardened selinux"' >> /etc/portage/make.conf
emerge --update --deep --newuse @world
emerge sys-apps/catalyst

# Hyprland
emerge gui-wm/hyprland x11-terms/kitty waybar wofi
useradd -m -G wheel,audio,video ghost
echo "ghost:ghost" | chpasswd

# Kernel và GRUB
emerge sys-kernel/gentoo-sources sys-boot/grub
cd /usr/src/linux
make defconfig
make -j$(nproc)
make modules_install
make install
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Services
rc-update add sshd default
rc-update add NetworkManager default
rc-update add elogind default

echo "Cài đặt xong!"
CHROOT_EOF

chmod +x /mnt/gentoo/install-inside.sh
chroot /mnt/gentoo /bin/bash /install-inside.sh

echo "=============================="
echo "HOÀN TẤT! Chạy lệnh sau:"
echo "exit"
echo "umount -R /mnt/gentoo"
echo "reboot"
