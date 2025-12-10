# 7. KIỂM TRA FSTAB
cat /etc/fstab

# 8. KIỂM TRA MOUNT TRONG CHROOT
mount | grep -E "(boot|home|var/tmp/portage)"

# 9. REINSTALL GRUB (CHO CHẮC)
grub-install --target=x86_64-efi --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg

# 10. KIỂM TRA BOOT FILES
ls -la /boot/