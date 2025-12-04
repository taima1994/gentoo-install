#!/bin/bash
set -e
echo "GHOST 2025 – BẮT ĐẦU CÀI GENTOO FULL HARDENED + SELINUX + HYPR LAND"
echo "================================================================"
echo "AUTO INSTALL 100% - KHÔNG CẦN CAN THIỆP SAU KHI REBOOT"
echo "================================================================"

# Tạo thư mục scripts
mkdir -p /tmp/ghost-scripts
cd /tmp/ghost-scripts

# Tải tất cả scripts
echo "Downloading installation scripts..."
for i in 1 2 3 4 5 6 7 8; do
  wget -q https://raw.githubusercontent.com/taima1994/gentoo-install/main/scripts/${i}-*.sh
  chmod +x ${i}-*.sh
done

# Chạy từng script với log
echo "Starting installation process..."
for script in 1-*.sh 2-*.sh 3-*.sh 4-*.sh 5-*.sh 6-*.sh 7-*.sh 8-*.sh; do
  echo "========================================"
  echo "Running: $script"
  echo "========================================"
  ./$script || {
    echo "ERROR in $script - Check above for details."
    echo "You can try to run manually: ./$script"
    exit 1
  }
done

echo ""
echo "================================================================"
echo "INSTALLATION COMPLETE! REBOOT NOW:"
echo "1. exit                           (để ra khỏi chroot)"
echo "2. umount -R /mnt/gentoo          (unmount tất cả)"
echo "3. reboot                         (khởi động lại)"
echo ""
echo "Sau khi reboot:"
echo "- Tự động login với user 'ghost' (password: ghost)"
echo "- Tự động start Hyprland"
echo "- Desktop ready to use!"
echo "================================================================"

# Giữ terminal mở để xem hướng dẫn
exec bash
