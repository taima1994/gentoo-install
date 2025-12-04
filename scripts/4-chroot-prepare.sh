#!/bin/bash
set -e
echo "4. CHUẨN BỊ CHROOT MÔI TRƯỜNG"
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
cp -L /etc/resolv.conf /mnt/gentoo/etc/

# Copy các script tiếp theo vào chroot
cp /tmp/scripts/5-*.sh /mnt/gentoo/
cp /tmp/scripts/6-*.sh /mnt/gentoo/
cp /tmp/scripts/7-*.sh /mnt/gentoo/
cp /tmp/scripts/8-*.sh /mnt/gentoo/

echo "VÀO CHROOT – CHẠY TIẾP CÁC SCRIPT 5-8"
chroot /mnt/gentoo /bin/bash << 'CHROOT_EOF'
source /etc/profile
export PS1="(GHOST-chroot) \$PS1"
cd /
chmod +x /5-*.sh /6-*.sh /7-*.sh /8-*.sh
echo "CHROOT THÀNH CÔNG – CHẠY ./5-full-install.sh TIẾP THEO"
CHROOT_EOF
