# 4.1 Sao chép DNS info
cp -L /etc/resolv.conf /mnt/gentoo/etc/

# 4.2 Mount các filesystem cần thiết
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev

# 4.3 Chroot vào hệ thống mới
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"
