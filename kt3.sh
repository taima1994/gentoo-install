# Chroot vào hệ thống
mount /dev/sdb3 /mnt/gentoo
mount /dev/sdb1 /mnt/gentoo/boot
mount /dev/sdb4 /mnt/gentoo/var/tmp/portage
# ... mount các phần còn lại

chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) $PS1"