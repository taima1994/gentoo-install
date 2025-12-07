# 4. Chroot prepare + bind mount
echo "4. CHROOT PREPARE..."
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
cp -L /etc/resolv.conf /mnt/gentoo/etc/

# Tạo script chroot – FIX TẤT CẢ LỖI (profile + torch + openmp + firmware + kernel)
cat > /mnt/gentoo/install-inside.sh << 'CHROOT_EOF'
#!/bin/bash
set -e
source /etc/profile

echo "========================================"
echo "GHOST 2025 - CÀI ĐẶT TRONG CHROOT (FIX TẤT CẢ LỖI)"
echo "========================================"

# FIX 1: KIỂM TRA VÀ CẤU HÌNH MÔI TRƯỜNG (profile + repos)
echo "1. Kiểm tra môi trường..."
export PATH="/usr/bin:/bin:/usr/sbin:/sbin"
mkdir -p /etc/portage/package.{use,unmask,license}
emerge --sync  # Sync profiles, fix /var/db/repos/gentoo empty

# FIX 2: SET PROFILE ĐÚNG (hardened/selinux, né invalid)
eselect profile list
eselect profile set 1  # default/linux/amd64/23.0/hardened/selinux
ls -l /etc/portage/make.profile  # Verify symlink OK
