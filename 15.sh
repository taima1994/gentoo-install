# 15. SELinux enforcing
setenforce 1

echo "========================================"
echo "✅ CÀI ĐẶT HOÀN TẤT 100%!"
echo "========================================"
echo "User: ghost / Password: ghost"
echo "Hostname: ghost-pc"
echo "Catalyst ready – chạy 'catalyst -f /etc/catalyst/ghost.spec' để build ISO!"
echo "Khởi động lại: exit → umount -R /mnt/gentoo → reboot"
CHROOT_EOF

chmod +x /mnt/gentoo/install-inside.sh
chroot /mnt/gentoo /bin/bash /install-inside.sh

echo "=============================="
echo "HOÀN TẤT! Chạy lệnh sau:"
echo "exit"
echo "umount -R /mnt/gentoo"
