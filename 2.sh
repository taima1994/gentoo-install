# 3.1 Chuyển vào thư mục mount
cd /mnt/gentoo
# 3.3 Tải stage3
wget https://gentoo.osuosl.org/releases/amd64/autobuilds/current-stage3-amd64-hardened-selinux-openrc/stage3-amd64-hardened-selinux-openrc-20251130T164554Z.tar.xz

# 3.4 Giải nén
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
