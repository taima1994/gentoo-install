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