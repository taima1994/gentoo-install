#!/bin/bash
# Ghost-Simple-OneShot: Total Basic Install (Dual Disk)

# Step1 Partition (echo commands)
echo "Partition sdb:"; echo "o n p 1 +512M t 1 ef n p 2 +8G t 2 82 n p 3 +100G t 3 83 n p 4  w" | fdisk /dev/sdb
mkfs.vfat -F32 /dev/sdb1; mkswap /dev/sdb2; mkfs.ext4 /dev/sdb3; mkfs.ext4 /dev/sdb4
echo "Partition sda:"; echo "o n p 1 +465G t 1 83 n p 2  w" | fdisk /dev/sda
mkfs.ext4 /dev/sda1; mkfs.ext4 /dev/sda2

mount /dev/sdb3 /mnt/gentoo; mkdir -p /mnt/gentoo/{boot,var}; mount /dev/sdb1 /mnt/gentoo/boot; mount /dev/sdb4 /mnt/gentoo/var; swapon /dev/sdb2

# Step2 Stage3
wget -O /tmp/stage3.tar.xz https://mirror.meowsmp.net/gentoo/releases/amd64/autobuilds/current-stage3-amd64-hardened-selinux-openrc/stage3-amd64-hardened-selinux-openrc-20251130T164554Z.tar.xz
tar xpf /tmp/stage3.tar.xz -C /mnt/gentoo; rm /tmp/stage3.tar.xz
cp /etc/resolv.conf /mnt/gentoo/etc/
mount --types proc /proc /mnt/gentoo/proc; mount --rbind /sys /mnt/gentoo/sys; mount --rbind /dev /mnt/gentoo/dev; mount --bind /run /mnt/gentoo/run

# Auto Chroot & Basic
chroot /mnt/gentoo /bin/bash -c "
source /etc/profile
eselect profile set default/linux/amd64/23.0/hardened/selinux
cat > /etc/portage/make.conf << EOF
COMMON_FLAGS='-march=native -O2 -pipe'
MAKEOPTS='-j\$(nproc)'
GENTOO_MIRRORS='https://mirror.meowsmp.net/gentoo'
EOF
wget -O /tmp/portage.tar.xz https://mirror.meowsmp.net/gentoo/snapshots/portage-latest.tar.xz; tar xpf /tmp/portage.tar.xz -C /usr/portage --strip-components=1; rm /tmp/portage.tar.xz; emerge --sync
emerge sys-kernel/gentoo-sources sys-kernel/genkernel sys-libs/gcc sys-boot/grub; genkernel all; grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB; grub-mkconfig -o /boot/grub/grub.cfg
mkdir -p /home /mnt/build; echo '/dev/sda1 /home ext4 defaults 0 2' >> /etc/fstab; echo '/dev/sda2 /mnt/build ext4 defaults 0 2' >> /etc/fstab
"

umount -R /mnt/gentoo; swapoff -a
echo "=== SIMPLE ONE-SHOT DONE! reboot ==="