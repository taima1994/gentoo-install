# 8.1 Cài GRUB
emerge --ask sys-boot/grub

# 8.2 Cài đặt GRUB
grub-install --target=x86_64-efi --efi-directory=/boot

# 8.3 Tạo config
grub-mkconfig -o /boot/grub/grub.cfg

# Add user
useradd -m -G wheel,audio,video -s /bin/bash long
passwd long

# Sudo
emerge --ask app-admin/sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Services
emerge --ask sys-process/cronie net-misc/openssh
rc-update add cronie default
rc-update add sshd default
