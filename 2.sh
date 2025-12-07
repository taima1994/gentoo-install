# 2. Format và mount
echo "2. FORMAT + MOUNT..."
mkfs.ext4 -F /dev/sda1
mkfs.ext4 -F /dev/sda2
mkfs.ext4 -F /dev/sdb1
mount /dev/sda1 /mnt/gentoo
mkdir -p /mnt/gentoo/{home,var/tmp/portage}
mount /dev/sda2 /mnt/gentoo/home
mount /dev/sdb1 /mnt/gentoo/var/tmp/portage
