#!/bin/bash
# Ghost Script 2: Stage3 Download & Chroot Setup v1.0
# Usage: ./script2.sh --mirror=vietnam --chaos=true

set -euo pipefail

MIRROR="${1:-vietnam}"
CHAOS="${2:-true}"

# Mirror config
case $MIRROR in
  vietnam) STAGE3_URL="https://mirror.meowsmp.net/gentoo/releases/amd64/autobuilds/current-stage3-amd64-hardened-selinux-openrc/stage3-amd64-hardened-selinux-openrc-20251130T164554Z.tar.xz"
           GENTOO_MIRRORS="https://mirror.meowsmp.net/gentoo" ;;
  *) STAGE3_URL="https://gentoo.osuosl.org/releases/amd64/autobuilds/current-stage3-amd64-hardened-selinux-openrc/stage3-amd64-hardened-selinux-openrc-20251130T164554Z.tar.xz"
     GENTOO_MIRRORS="https://distfiles.gentoo.org" ;;
esac

pip install torch requests tqdm --quiet

# Forecast download
python3 -c "
import torch; import requests; import time
start = time.time(); r = requests.head('$STAGE3_URL'); latency = time.time() - start
print(f'Forecast: Latency {latency:.2f}s - {'Fast' if latency < 0.5 else 'OK'}')
"

# Download & Extract
wget -q --tries=3 $STAGE3_URL -O /tmp/stage3.tar.xz || wget -q https://mirror.meowsmp.net/gentoo/releases/amd64/autobuilds/current-stage3-amd64-hardened-selinux-openrc/stage3-amd64-hardened-selinux-openrc-20251130T164554Z.tar.xz -O /tmp/stage3.tar.xz
tar xpf /tmp/stage3.tar.xz -C /mnt/gentoo --xattrs-include="*.*" --numeric-owner
rm /tmp/stage3.tar.xz  # Cleanup

cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

# Bind mounts
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys && mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev && mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run && mount --make-slave /mnt/gentoo/run

# Test: Check extract
ls /mnt/gentoo/bin/bash && echo "[GHOST2] Chroot ready" || { echo "Error: Extract failed"; exit 1; }

echo "[GHOST2] Complete! Now enter chroot manually: chroot /mnt/gentoo /bin/bash, then source /etc/profile, then run Script 3 inside chroot."
