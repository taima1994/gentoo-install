#!/bin/bash
set -e
echo "4. CHUẨN BỊ CHROOT MÔI TRƯỜNG"

# Mount các filesystem
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
cp -L /etc/resolv.conf /mnt/gentoo/etc/

# Copy scripts 5-8 vào chroot
echo "Copying scripts 5-8 into chroot..."
cp /tmp/ghost-scripts/5-*.sh /mnt/gentoo/
cp /tmp/ghost-scripts/6-*.sh /mnt/gentoo/
cp /tmp/ghost-scripts/7-*.sh /mnt/gentoo/
cp /tmp/ghost-scripts/8-*.sh /mnt/gentoo/

# Tạo script chạy tự động trong chroot
cat > /mnt/gentoo/continue_install.sh << 'EOF'
#!/bin/bash
set -e
source /etc/profile
export PS1="(GHOST-chroot) \$PS1"
cd /

# Chạy các script 5-8
echo "=== Running script 5: Full Install ==="
chmod +x /5-*.sh && /5-*.sh

echo "=== Running script 6: Hyprland Setup ==="
chmod +x /6-*.sh && /6-*.sh

echo "=== Running script 7: Kernel & GRUB ==="
chmod +x /7-*.sh && /7-*.sh

echo "=== Running script 8: Final Config ==="
chmod +x /8-*.sh && /8-*.sh

# Cleanup
rm -f /5-*.sh /6-*.sh /7-*.sh /8-*.sh /continue_install.sh
echo "=== All chroot scripts completed! ==="
EOF

chmod +x /mnt/gentoo/continue_install.sh

echo "Entering chroot environment..."
chroot /mnt/gentoo /bin/bash -c "/continue_install.sh"

echo "CHROOT VÀ CÀI ĐẶT CÁC PHẦN TIẾP THEO XONG!"
