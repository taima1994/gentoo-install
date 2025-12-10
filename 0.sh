# 5. CHROOT VÀO
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) $PS1"

# 6. FIX FSTAB TỰ ĐỘNG
cat > /tmp/fix-fstab.sh << 'EOF'
#!/bin/bash
echo "Fixing /etc/fstab..."

# Backup old fstab
cp /etc/fstab /etc/fstab.backup

# Create new fstab with correct UUIDs
cat > /etc/fstab << 'FSTAB_EOF'
# /etc/fstab: static file system information

# ROOT - SSD sdb3
$(blkid /dev/sdb3 -s UUID -o value) / ext4 defaults,noatime,discard 0 1

# BOOT - SSD sdb1  
$(blkid /dev/sdb1 -s UUID -o value) /boot vfat defaults,noatime 0 2

# SWAP - SSD sdb2
/dev/sdb2 none swap sw 0 0

# PORTAGE TEMP - SSD sdb4
$(blkid /dev/sdb4 -s UUID -o value) /var/tmp/portage ext4 defaults,noatime,discard 0 2

# HOME - HDD sda1
$(blkid /dev/sda1 -s UUID -o value) /home ext4 defaults,noatime 0 2

# BINPKGS - HDD sda2
$(blkid /dev/sda2 -s UUID -o value) /var/cache/binpkgs ext4 defaults,noatime 0 2

# PORTAGE TREE - HDD sda3
$(blkid /dev/sda3 -s UUID -o value) /var/db/repos ext4 defaults,noatime 0 2

# ISO STORAGE - HDD sda4
$(blkid /dev/sda4 -s UUID -o value) /mnt/iso-storage ext4 defaults,noatime 0 2
FSTAB_EOF

echo "New fstab created:"
cat /etc/fstab
EOF

chmod +x /tmp/fix-fstab.sh
/tmp/fix-fstab.sh