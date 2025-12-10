# 8.1 Cài GRUB
emerge --ask sys-boot/grub

# 8.2 Cài đặt GRUB
grub-install --target=x86_64-efi --efi-directory=/boot

# 8.3 Tạo config
grub-mkconfig -o /boot/grub/grub.cfg
