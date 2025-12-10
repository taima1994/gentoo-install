
# Chroot vào
mount /dev/sdb3 /mnt/gentoo
mount /dev/sdb1 /mnt/gentoo/boot
mount /dev/sda1 /mnt/gentoo/home
# ... mount các phần còn lại

chroot /mnt/gentoo /bin/bash
source /etc/profile