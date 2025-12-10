# 8.1 Cài GRUB
emerge --ask sys-boot/grub

# 8.2 Cài đặt GRUB
grub-install --target=x86_64-efi --efi-directory=/boot

# 8.3 Tạo config
grub-mkconfig -o /boot/grub/grub.cfg


# 9.1 Cài đặt tools hệ thống
emerge --ask app-admin/sysklogd
rc-update add sysklogd default

emerge --ask sys-process/cronie
rc-update add cronie default

# 9.2 Cài đặt SSH
emerge --ask net-misc/openssh
rc-update add sshd default

# 9.3 Cài đặt file indexing
emerge --ask sys-apps/mlocate

# 9.4 Cài đặt sudo
emerge --ask app-admin/sudo
