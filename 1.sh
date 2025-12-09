# Xóa bảng phân vùng cũ (CHỈ LÀM NẾU KHÔNG CÓ DATA QUAN TRỌNG)
wipefs -a /dev/sda
wipefs -a /dev/sdb

# SSD partitions
mkfs.fat -F 32 /dev/sdb1          # boot (UEFI)
mkswap /dev/sdb2                  # swap
swapon /dev/sdb2
mkfs.ext4 /dev/sdb3               # root
mkfs.ext4 /dev/sdb4               # portage temp

# HDD partitions
mkfs.ext4 /dev/sda1               # home
mkfs.ext4 /dev/sda2               # binpkgs cache
mkfs.ext4 /dev/sda3               # portage tree
mkfs.ext4 /dev/sda4               # iso storage

# Tối ưu ext4 cho SSD (noatime, discard)
tune2fs -o discard /dev/sdb3
tune2fs -o discard /dev/sdb4

# Root trước
mount /dev/sdb3 /mnt/gentoo

# Tạo thư mục và mount boot
mkdir -p /mnt/gentoo/boot
mount /dev/sdb1 /mnt/gentoo/boot

# Tạo và mount thư mục portage temp (SSD - để build nhanh)
mkdir -p /mnt/gentoo/var/tmp/portage
mount /dev/sdb4 /mnt/gentoo/var/tmp/portage

# Mount HDD partitions
mkdir -p /mnt/gentoo/home
mount /dev/sda1 /mnt/gentoo/home

mkdir -p /mnt/gentoo/var/cache/binpkgs
mount /dev/sda2 /mnt/gentoo/var/cache/binpkgs

mkdir -p /mnt/gentoo/var/db/repos/gentoo
mount /dev/sda3 /mnt/gentoo/var/db/repos/gentoo

mkdir -p /mnt/gentoo/mnt/iso-storage
mount /dev/sda4 /mnt/gentoo/mnt/iso-storage
