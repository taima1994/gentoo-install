cp -L /etc/resolv.conf etc/
mount --types proc /proc proc
mount --rbind /sys sys
mount --rbind /dev dev
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) $PS1"
