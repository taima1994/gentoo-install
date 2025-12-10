# Xem mount hiện tại
mount | grep /boot

# Unmount cái sai
umount /boot

# Mount đúng phân vùng boot
mount /dev/sdb1 /boot

# Kiểm tra lại
lsblk
df -h | grep boot