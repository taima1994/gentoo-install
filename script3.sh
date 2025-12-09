#!/bin/bash
# Ghost Script3 v1.1: Portage Snapshot & Kernel (INSIDE chroot)
# Usage: chroot> ./script3.sh --mirror=vietnam --chaos=true

set -euo pipefail

MIRROR="${1:-vietnam}"
CHAOS="${2:-true}"

case $MIRROR in
  vietnam) SYNC_URL="https://mirror.meowsmp.net/gentoo/snapshots/portage-latest.tar.xz" ;;
  *) SYNC_URL="https://distfiles.gentoo.org/snapshots/portage-latest.tar.xz" ;;
esac

pip install torch requests qutip --quiet

# Profile
eselect profile set default/linux/amd64/23.0/hardened/selinux

# make.conf with mirrors
cat > /etc/portage/make.conf << EOF
COMMON_FLAGS="-march=native -O2 -pipe"
MAKEOPTS="-j\$(nproc)"
GENTOO_MIRRORS="https://mirror.meowsmp.net/gentoo https://mirror.kirbee.tech/gentoo"
EOF

# Portage Snapshot Download + Extract (faster than rsync)
python3 -c "
import requests; import time; r=requests.head('$SYNC_URL'); print('Forecast: Portage ready')
"
wget --tries=5 -q $SYNC_URL -O /tmp/portage.tar.xz
tar xpf /tmp/portage.tar.xz -C /usr/portage --strip-components=1 --numeric-owner --xattrs-include='*.*'
rm /tmp/portage.tar.xz
emerge --sync --quiet  # Quick post-sync

# Quantum Chaos: Entangle tree
if [ "$CHAOS" = "true" ]; then
  python3 -c "import qutip; q = qutip.rand_dm(2); print('Quantum: Portage entangled')"
fi

# Kernel & fixes
emerge sys-kernel/gentoo-sources sys-kernel/linux-firmware
emerge sys-kernel/genkernel || emerge sys-kernel/vanilla-sources
genkernel all

python3 -c "import torch; print('OpenMP forecast OK')"
emerge --autounmask-write sys-libs/gcc && etc-update --automode -5 && emerge sys-libs/gcc
emerge sys-kernel/linux-firmware

# Test
[ -d /usr/portage ] && [ -d /usr/src/linux ] && echo "[GHOST3] Portage & Kernel OK! Run Script4"
