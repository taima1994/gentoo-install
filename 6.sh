# 6.1 Cài đặt kernel sources
emerge --ask sys-kernel/gentoo-sources

# 6.2 Cài đặt genkernel (cho dễ)
emerge --ask sys-kernel/genkernel

# 6.3 Sao chép config mặc định
cd /usr/src/linux
zcat /proc/config.gz > .config

# 6.4 Cấu hình kernel (tùy chọn)
# make menuconfig  # Nếu muốn tùy chỉnh

# 6.5 Biên dịch kernel với genkernel
genkernel all

# 6.6 Cài đặt firmware
emerge --ask sys-kernel/linux-firmware

# 7.1 Tạo file fstab
blkid  # Lấy UUID các partition
nano /etc/fstab
# Thêm các dòng:
# UUID=[UUID_ROOT] / ext4 defaults,noatime 0 1
# UUID=[UUID_BOOT] /boot vfat defaults 0 2
# UUID=[UUID_SWAP] none swap sw 0 0

# 7.2 Đặt hostname
nano /etc/conf.d/hostname
# hostname="gentoo"

# 7.3 Cấu hình network
emerge --ask net-misc/dhcpcd
# Hoặc netifrc:
emerge --ask net-misc/netifrc

# Cấu hình cho eth0:
cd /etc/init.d
ln -s net.lo net.eth0
rc-update add net.eth0 default

# 7.4 Đặt root password
passwd

