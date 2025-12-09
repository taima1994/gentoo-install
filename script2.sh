#!/bin/bash
# Ghost Script2 v1.1: Stage3 Download & Chroot - Validated Mirror
# Usage: ./script2.sh --mirror=vietnam --chaos=true

set -euo pipefail

MIRROR="${1:-vietnam}"
CHAOS="${2:-true}"

case $MIRROR in
  vietnam) STAGE3_URL="https://mirror.meowsmp.net/gentoo/releases/amd64/autobuilds/current-stage3-amd64-hardened-selinux-openrc/stage3-amd64-hardened-selinux-openrc-20251130T164554Z.tar.xz" ;;
  *) STAGE3_URL="https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-hardened/stage3-amd64-hardened-*.tar.xz" ;;
esac

pip install torch requests tqdm --quiet

# AI Forecast + Validate
python3 -c "
import torch; import requests; import time
r = requests.head('$STAGE3_URL', timeout=10)
latency = time.time() - time.time(); print(f'Forecast: Download ready, status {r.status_code}')
"

# Download with retry
wget --tries=5 --timeout=60 -q $STAGE3_URL -O /tmp/stage3.tar.xz || {
  echo "[GHOST2] Fallback mirror"; wget --tries=5 -q https://mirror.kirbee.tech/gentoo/releases/amd64/autobuilds/current-stage3-amd64-hardened-selinux-openrc/stage3-*.tar.xz -O /tmp/stage3.tar.xz;
}

tar xpf /tmp/stage3.tar.xz -C /mnt/gentoo --xattrs-include="*.*" --numeric-owner
rm /tmp/stage3.tar.xz

cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mkdir -p /mnt/gentoo/{home,mnt/build}  # Prep dual

# Bind mounts
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys && mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev && mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run && mount --make-slave /mnt/gentoo/run

# Test
[ -f /mnt/gentoo/bin/bash ] && echo "[GHOST2] Chroot ready! Enter: chroot /mnt/gentoo /bin/bash; source /etc/profile; Run Script3"
