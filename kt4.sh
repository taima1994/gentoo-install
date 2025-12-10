# Đảm bảo /boot được mount
mount /dev/sdb1 /boot

# Cài lại GRUB
grub-install --target=x86_64-efi --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg

# Kiểm tra mount
mount | grep /boot
# Phải chỉ có: /dev/sdb1 on /boot type vfat

# Kiểm tra boot files
ls -la /boot/
# Phải có: grub/ efi/ vmlinuz-... initramfs-...

# Kiểm tra fstab
cat /etc/fstab

