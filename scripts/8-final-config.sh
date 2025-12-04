#!/bin/bash
set -e
echo "8. CẤU HÌNH CUỐI CÙNG + AUTO START"

# Enable các service
rc-update add sshd default
rc-update add dbus default
rc-update add elogind default
rc-update add NetworkManager default
rc-update add local default  # Cho autostart script

# Cài đặt network manager GUI
emerge net-misc/networkmanager net-wireless/iwd network-manager-applet
rc-update add iwd default

# Cấu hình network
cat > /etc/NetworkManager/NetworkManager.conf << 'EOF'
[main]
plugins=iwd,keyfile
dhcp=dhcpcd

[device]
wifi.backend=iwd
EOF

# Cấu hình auto connect WiFi (nếu cần)
mkdir -p /etc/iwd
cat > /etc/iwd/main.conf << 'EOF'
[General]
EnableNetworkConfiguration=true

[Network]
NameResolvingService=systemd
EOF

# Cấu hình timezone và locale
echo "Asia/Ho_Chi_Minh" > /etc/timezone
emerge --config sys-libs/timezone-data
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "vi_VN UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set en_US.utf8

# Cấu hình hostname
echo "ghost-gentoo" > /etc/hostname
cat >> /etc/hosts << 'EOF'
127.0.0.1   localhost
::1         localhost
127.0.1.1   ghost-gentoo.localdomain ghost-gentoo
EOF

# Cấu hình fstab tối ưu
cat >> /etc/fstab << 'EOF'
# Tối ưu SSD
/dev/sda1   /       ext4    noatime,discard,errors=remount-ro   0 1
/dev/sda2   /home   ext4    noatime,discard,nodev,nosuid        0 2
/dev/sdb1   /var/tmp/portage ext4 noatime,nodev,nosuid          0 2
tmpfs       /tmp    tmpfs   defaults,noatime,nosuid,nodev,size=4G  0 0
tmpfs       /var/tmp tmpfs  defaults,noatime,nosuid,nodev,size=2G  0 0
EOF

# Cập nhật environment
env-update && source /etc/profile

# Cài đặt thêm tiện ích
emerge app-misc/neofetch app-editors/nano sys-process/htop \
  net-misc/curl net-misc/wget app-misc/tmux

# Tạo file chào mừng
cat > /home/ghost/.bashrc << 'EOF'
# GHOST 2025 - Gentoo Hardened
echo ""
neofetch
echo ""
echo "Welcome to GHOST 2025 - Gentoo Hardened + SELinux + Hyprland"
echo "System is ready! Auto-login enabled for user 'ghost'"
echo "Password for ghost: ghost"
echo ""
EOF

chown ghost:ghost /home/ghost/.bashrc

echo "================================================================"
echo "HOÀN TẤT 100%! Hệ thống sẽ tự động:"
echo "1. Auto login user 'ghost' trên tty1"
echo "2. Tự động start Hyprland"
echo "3. Ready to use desktop!"
echo ""
echo "CHẠY LỆNH SAU ĐỂ REBOOT:"
echo "exit"
echo "umount -R /mnt/gentoo"
echo "reboot"
echo "================================================================"
