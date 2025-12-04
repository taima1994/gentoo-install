#!/bin/bash
set -e
echo "1. PHÂN VÙNG SDA (SSD) + SDB (HDD) TỐI ƯU BUILD GHOST"
echo "================================================================"
echo "CẢNH BÁO: Tất cả dữ liệu trên /dev/sda và /dev/sdb sẽ bị xóa!"
echo "Chỉ tiếp tục nếu bạn đã backup dữ liệu quan trọng."
echo "================================================================"

# Yêu cầu xác nhận
read -p "Nhập 'YES' để tiếp tục phân vùng: " confirm
if [ "$confirm" != "YES" ]; then
  echo "Hủy bỏ phân vùng."
  exit 1
fi

# Phân vùng /dev/sda (SSD)
echo "Phân vùng /dev/sda (SSD)..."
parted -s /dev/sda mklabel gpt
parted -s /dev/sda mkpart primary 1MiB 200GiB   # root
parted -s /dev/sda mkpart primary 200GiB 100%   # /home

# Phân vùng /dev/sdb (HDD)
echo "Phân vùng /dev/sdb (HDD)..."
parted -s /dev/sdb mklabel gpt
parted -s /dev/sdb mkpart primary 1MiB 100%     # /var/tmp/portage

echo "PHÂN VÙNG XONG!"
parted -l
