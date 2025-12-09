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
