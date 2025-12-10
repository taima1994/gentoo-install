# 1. XEM TÌNH TRẠNG HIỆN TẠI
mount | grep /mnt/gentoo

# 2. UNMOUNT TẤT CẢ
umount -R /mnt/gentoo

# 3. MOUNT LẠI TỪ ĐẦU - ĐÚNG CHUẨN
mount /dev/sdb3 /mnt/gentoo                      # root
mount /dev/sdb1 /mnt/gentoo/boot                 # boot (SSD 1G)
mount /dev/sdb4 /mnt/gentoo/var/tmp/portage      # portage temp
mount /dev/sda1 /mnt/gentoo/home                 # home
mount /dev/sda2 /mnt/gentoo/var/cache/binpkgs    # binpkgs
mount /dev/sda3 /mnt/gentoo/var/db/repos         # portage tree
mount /dev/sda4 /mnt/gentoo/mnt/iso-storage      # iso storage

# 4. KIỂM TRA
mount | grep /mnt/gentoo
# Phải thấy:
# /dev/sdb3 on /mnt/gentoo type ext4
# /dev/sdb1 on /mnt/gentoo/boot type vfat
# /dev/sda1 on /mnt/gentoo/home type ext4
# KHÔNG có 2 boot!