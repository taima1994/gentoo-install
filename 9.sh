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
