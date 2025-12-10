# Unmount các phân vùng sai khỏi /boot
umount /dev/sdb2  # Đây là SWAP, không phải boot!
umount /dev/sda1  # Đây là /home, không phải boot!