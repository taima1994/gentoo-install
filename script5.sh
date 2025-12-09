#!/bin/bash
# Script5-Simple: Finalize (IN CHROOT first)

echo "=== GHOST5: GRUB & SELinux ==="
emerge sys-boot/grub
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

echo "Fstab dual:"
mkdir -p /home /mnt/build
cat >> /etc/fstab << EOF
/dev/sda1 /home ext4 defaults 0 2
/dev/sda2 /mnt/build ext4 defaults 0 2
EOF
mount -a

echo "Test basic: mount -a OK? Y: Chạy 'exit' chroot."

echo "=== GHOST5 CHROOT DONE! exit chroot, rồi umount dưới ==="

# --- NGỒI CHROOT: Copy phần dưới chạy ngoài ---
# Umount (chạy ngoài chroot):
umount /mnt/gentoo/var
umount /mnt/gentoo/boot
umount /mnt/gentoo/dev{/shm,/pts,} 2>/dev/null || true
umount -R /mnt/gentoo
swapoff -a
echo "Umount OK! reboot"