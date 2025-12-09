# 10.1 Thêm user
useradd -m -G users,wheel,audio,video -s /bin/bash [username]
passwd [username]

# 10.2 Cấu hình sudo
visudo
# Bỏ comment dòng: %wheel ALL=(ALL) ALL

# 10.3 Thoát chroot
exit
cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
reboot
