#!/bin/bash
echo "=== SPRIT 7: AUTO SYSTEM CONFIG ==="

# 7.1 Auto fstab (tự động lấy UUID)
echo "Creating /etc/fstab..."
cat > /etc/fstab << EOF
# /etc/fstab: static file system information
#
# <file system>    <mount point>    <type>    <options>        <dump>  <pass>

# Root partition (auto-detected)
$(blkid /dev/sdb3 -o export | grep UUID= | sed 's/^/UUID=/') / ext4 defaults,noatime,discard 0 1

# Boot partition (auto-detected)
$(blkid /dev/sdb1 -o export | grep UUID= | sed 's/^/UUID=/') /boot vfat defaults,noatime 0 2

# Swap (không cần UUID)
/dev/sdb2 none swap sw 0 0

# Portage temp
$(blkid /dev/sdb4 -o export | grep UUID= | sed 's/^/UUID=/') /var/tmp/portage ext4 defaults,noatime,discard 0 2

# Home
$(blkid /dev/sda1 -o export | grep UUID= | sed 's/^/UUID=/') /home ext4 defaults,noatime 0 2

# Binpkgs cache
$(blkid /dev/sda2 -o export | grep UUID= | sed 's/^/UUID=/') /var/cache/binpkgs ext4 defaults,noatime 0 2

# Portage tree
$(blkid /dev/sda3 -o export | grep UUID= | sed 's/^/UUID=/') /var/db/repos ext4 defaults,noatime 0 2

# ISO storage
$(blkid /dev/sda4 -o export | grep UUID= | sed 's/^/UUID=/') /mnt/iso-storage ext4 defaults,noatime 0 2
EOF

echo "Fstab created successfully!"
cat /etc/fstab

# 7.2 Auto hostname
echo "Setting hostname to 'gentoo'..."
echo "hostname=\"gentoo\"" > /etc/conf.d/hostname

# 7.3 Auto network (chọn dhcpcd đơn giản)
echo "Installing network tools..."
emerge --quiet net-misc/dhcpcd

# Auto detect network interface (lấy interface đầu tiên không phải lo)
INTERFACE=$(ip link show | grep -E "^[0-9]+:" | grep -v lo | head -1 | cut -d: -f2 | xargs)
if [ ! -z "$INTERFACE" ]; then
    echo "Configuring network for interface: $INTERFACE"
    ln -sf /etc/init.d/net.lo /etc/init.d/net.$INTERFACE
    rc-update add net.$INTERFACE default
else
    echo "Warning: No network interface found!"
fi

# 7.4 Auto root password (đặt mặc định là 'gentoo')
echo "Setting root password to 'gentoo'..."
echo "root:gentoo" | chpasswd

echo "=== SPRIT 7 COMPLETE ==="
echo "Root password: gentoo (change after first login!)"
