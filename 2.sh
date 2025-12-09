# 3.1 Chuyển vào thư mục mount
cd /mnt/gentoo

# 3.2 Tải stage3 mới nhất (chọn đúng kiến trúc)
links https://www.gentoo.org/downloads/
# Hoặc dùng wget:
wget https://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-desktop-openrc.txt
# Xem file vừa tải để biết tên stage3 chính xác

# 3.3 Tải stage3
wget [URL_STAGE3_TỪ_FILE_TRÊN]

# 3.4 Giải nén
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
