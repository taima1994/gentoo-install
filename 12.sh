# Thoát chroot
exit

# Unmount theo thứ tự
umount /mnt/gentoo/var/tmp/portage
umount /mnt/gentoo/var/cache/binpkgs
umount /mnt/gentoo/var/db/repos
umount /mnt/gentoo/home
umount /mnt/gentoo/mnt/iso-storage
umount /mnt/gentoo/boot
umount /mnt/gentoo

# Hoặc dùng lệnh nhanh
umount -R /mnt/gentoo

# Reboot
reboot