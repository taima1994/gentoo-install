# Tìm phân vùng boot thật (sdb1)
lsblk | grep sdb1

# Mount đúng phân vùng boot
mount /dev/sdb1 /boot

# Kiểm tra
mount | grep /boot
# Phải chỉ thấy: /dev/sdb1 on /boot type vfat