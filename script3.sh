#!/bin/bash
# Script3-Simple: Portage & Kernel (IN CHROOT) - No pip early

PORTAGE_URL="https://mirror.meowsmp.net/gentoo/snapshots/portage-latest.tar.xz"

echo "=== GHOST3: Set profile hardened ==="
eselect profile set default/linux/amd64/23.0/hardened/selinux

echo "make.conf:"
cat > /etc/portage/make.conf << EOF
COMMON_FLAGS="-march=native -O2 -pipe"
MAKEOPTS="-j\$(nproc)"
GENTOO_MIRRORS="https://mirror.meowsmp.net/gentoo"
EOF

echo "Tải portage snapshot:"
wget --tries=3 -O /tmp/portage.tar.xz $PORTAGE_URL || {
  echo "Lỗi? Manual: wget [URL]"; exit 1;
}
tar xpf /tmp/portage.tar.xz -C /usr/portage --strip-components=1
rm /tmp/portage.tar.xz
emerge --sync --quiet

echo "Kernel:"
emerge sys-kernel/gentoo-sources sys-kernel/linux-firmware
emerge sys-kernel/genkernel || echo "Fallback vanilla-sources"
genkernel all

emerge sys-libs/gcc sys-kernel/linux-firmware

echo "=== GHOST3 HOÀN THÀNH! Check: ls /usr/src/linux. Chạy Script4 ==="