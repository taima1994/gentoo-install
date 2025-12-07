# 10. Cấu hình fstab
echo "10. Cấu hình fstab..."
cat > /etc/fstab << 'EOF'
/dev/sda1    /               ext4    noatime,errors=remount-ro    0 1
/dev/sda2    /home           ext4    defaults,noatime             0 2
/dev/sdb1    /var/tmp/portage ext4  defaults,noatime              0 2
EOF
