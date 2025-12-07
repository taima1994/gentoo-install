# 1. Phân vùng sda (SSD 931.5G) + sdb (HDD 223.6G) tối ưu compile GHOST
echo "1. PHÂN VÙNG SDA + SDB TỐI ƯU..."
parted -s /dev/sda mklabel gpt
parted -s /dev/sda mkpart primary 1MiB 200GiB   # root
parted -s /dev/sda mkpart primary 200GiB 100%   # /home
parted -s /dev/sdb mklabel gpt
parted -s /dev/sdb mkpart primary 1MiB 100%     # /var/tmp/portage compile nhanh
