#!/bin/bash
set -e
echo "5. CÀI ĐẶT GENTOO FULL + CATALYST"

# Cấu hình mirror gần Việt Nam
mkdir -p /etc/portage/repos.conf
cat > /etc/portage/repos.conf/gentoo.conf << 'EOF'
[DEFAULT]
main-repo = gentoo

[gentoo]
location = /usr/portage
sync-type = rsync
sync-uri = rsync://rsync.mirrors.ustc.edu.cn/gentoo-portage/
auto-sync = yes
sync-rsync-verify-jobs = 1
sync-rsync-verify-metamanifest = yes
sync-rsync-verify-max-age = 24
sync-rsync-extra-opts = 
EOF

emerge-webrsync

# Cấu hình make.conf tối ưu
cat >> /etc/portage/make.conf << 'EOF'
# GHOST 2025 Optimizations
MAKEOPTS="-j$(nproc) -l$(($(nproc)*2/3))"
EMERGE_DEFAULT_OPTS="--jobs=$(($(nproc)+1)) --load-average=$(($(nproc)*2/3))"
FEATURES="parallel-fetch parallel-install candy"
USE="hardened selinux X wayland vulkan pulseaudio -gnome -kde -systemd"
ACCEPT_KEYWORDS="amd64 ~amd64"
ACCEPT_LICENSE="*"
VIDEO_CARDS="amdgpu radeonsi"
EOF

emerge --update --deep --newuse @world
emerge app-portage/cpuid2cpuflags
echo "*/* $(cpuid2cpuflags)" >> /etc/portage/package.use/00cpu-flags

# Cài đặt catalyst và công cụ build
emerge sys-apps/catalyst sys-process/icecream sys-process/ccache app-portage/layman

# Cấu hình SELinux
emerge sys-apps/policycoreutils
sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
setenforce 0  # Tạm thời permissive để cài đặt
echo "FULL GENTOO + CATALYST XONG!"
