# 1. Tạo thư mục mount
mkdir -p /mnt/gentoo

# 2. Mount root partition (sdb3)
mount /dev/sdb3 /mnt/gentoo

# 3. Chroot vào
chroot /mnt/gentoo /bin/bash

# 4. Source profile
source /etc/profile
export PS1="(chroot) $PS1"