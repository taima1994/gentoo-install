#!/bin/bash
# Script2-Simple: Tải Stage3 & Mount - No pip

STAGE3_URL="https://mirror.meowsmp.net/gentoo/releases/amd64/autobuilds/current-stage3-amd64-hardened-selinux-openrc/stage3-amd64-hardened-selinux-openrc-20251130T164554Z.tar.xz"

echo "=== GHOST2: Tải stage3 từ VN mirror ($STAGE3_URL) ==="
wget --tries=3 -O /tmp/stage3.tar.xz $STAGE3_URL || {
  echo "Lỗi tải? Copy manual: wget [URL trên]"; exit 1;
}
echo "Tải OK, extract..."

tar xpf /tmp/stage3.tar.xz -C /mnt/gentoo
rm /tmp/stage3.tar.xz
cp /etc/resolv.conf /mnt/gentoo/etc/
mkdir -p /mnt/gentoo/{home,mnt/build}

echo "Bind mounts:"
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run

echo "=== GHOST2 HOÀN THÀNH! Vào chroot: chroot /mnt/gentoo /bin/bash; source /etc/profile; Chạy Script3 ==="
[ -f /mnt/gentoo/bin/bash ] && echo "Chroot ready" || echo "Lỗi extract?"