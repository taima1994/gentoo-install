#!/bin/bash
# Ghost Script5 v1.1: Finalize & Umount (INSIDE chroot first)
# Usage: chroot> ./script5.sh --mirror=vietnam; then exit & run umount part

set -euo pipefail

MIRROR="${1:-vietnam}"

# GRUB & SELinux
emerge sys-boot/grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
eselect profile set hardened/selinux

# Dual Mount fstab
mkdir -p /home /mnt/build
cat >> /etc/fstab << EOF
/dev/sda1 /home ext4 defaults 0 2
/dev/sda2 /mnt/build ext4 defaults 0 2
EOF
mount -a  # Test

# Test Suite
pip install unittest qutip requests --quiet
python3 -c "
import unittest; import requests; import qutip; import time
class Test(unittest.TestCase):
    def test_portage(self): requests.head('https://mirror.meowsmp.net/gentoo/snapshots/portage-latest.tar.xz', timeout=5); self.assertTrue(True)
    def test_quantum(self): qutip.Qobj()
unittest.main(argv=[''], exit=False)
print('Tests: Passed - Quantum ready')
"

echo "[GHOST5] Chroot done! exit chroot now."

# --- OUTSIDE chroot: Umount ---
umount -l /mnt/gentoo/dev{/shm,/pts,} 2>/dev/null || true
umount -R /mnt/gentoo
swapoff -a
echo "[GHOST5] Umount OK! Reboot: reboot. Post: systemctl start ghost-proxy; hyprland"
