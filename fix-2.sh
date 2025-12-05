#!/bin/bash
# ========================================
# FIX HOÀN TOÀN PORTAGE & EBUILDS
# ========================================

set -e

echo "🚀 Bắt đầu fix toàn bộ Portage system..."

# 1. XÓA VÀ TẢI LẠI TOÀN BỘ PORTAGE
echo "1. Tải lại Portage tree..."
rm -rf /var/db/repos/gentoo
mkdir -p /var/db/repos/gentoo
cd /var/db/repos/gentoo

# Tải portage snapshot mới nhất
wget -q --show-progress https://mirror.meowsmp.net/gentoo/snapshots/portage-latest.tar.xz
tar xpf portage-latest.tar.xz --strip-components=1
rm -f portage-latest.tar.xz

# 2. CẤU HÌNH REPOSITORY
echo "2. Cấu hình repository..."
cat > /etc/portage/repos.conf/gentoo.conf << 'EOF'
[gentoo]
location = /var/db/repos/gentoo
sync-type = rsync
sync-uri = rsync://rsync.gentoo.org/gentoo-portage
auto-sync = yes
sync-rsync-verify-jobs = 1
sync-rsync-verify-metamanifest = yes
sync-rsync-verify-max-age = 24
sync-openpgp-key-path = /usr/share/openpgp-keys/gentoo-release.asc
sync-openpgp-key-refresh-retry-count = 40
sync-openpgp-key-refresh-retry-overall-timeout = 1200
sync-openpgp-key-refresh-retry-delay-exp-base = 2
sync-openpgp-key-refresh-retry-delay-max = 60
sync-openpgp-key-refresh-retry-delay-mult = 1
EOF

# 3. CHỌN PROFILE
echo "3. Chọn profile..."
# Liệt kê và chọn profile mặc định
eselect profile list
DEFAULT_PROFILE=$(eselect profile list | grep "default/linux/amd64/17.1" | head -1 | awk '{print $1}' | tr -d '[]')
if [ -n "$DEFAULT_PROFILE" ]; then
    eselect profile set $DEFAULT_PROFILE
else
    # Chọn cái đầu tiên
    eselect profile set 1
fi

# 4. CẬP NHẬT PORTAGE BẰNG WEBRSYNC
echo "4. Đồng bộ Portage..."
emerge-webrsync --quiet

# 5. CÀI ĐẶT CÁC GÓI CƠ BẢN BẰNG TAY
echo "5. Cài đặt công cụ cơ bản..."

# Tạo danh sách gói cần thiết
cat > /tmp/essential-packages.txt << 'EOF'
sys-devel/make
sys-devel/gcc
sys-devel/binutils
sys-libs/glibc
sys-apps/baselayout
sys-apps/portage
sys-apps/openrc
app-shells/bash
sys-apps/coreutils
sys-apps/findutils
sys-apps/grep
sys-apps/sed
sys-apps/gawk
sys-apps/file
sys-apps/less
EOF

# Cài từng gói
while read pkg; do
    if [ -n "$pkg" ]; then
        echo "📦 Cài $pkg..."
        emerge --oneshot --quiet-build $pkg || \
        echo "⚠️  Lỗi cài $pkg, tiếp tục..."
    fi
done < /tmp/essential-packages.txt

# 6. CẬP NHẬT HỆ THỐNG
echo "6. Cập nhật hệ thống..."
emerge --update --deep --newuse @system --quiet-build

# 7. KIỂM TRA
echo "7. Kiểm tra hệ thống..."
echo "✅ Make: $(make --version 2>/dev/null | head -1 || echo 'Chưa cài')"
echo "✅ GCC: $(gcc --version 2>/dev/null | head -1 || echo 'Chưa cài')"
echo "✅ Portage: $(emerge --version 2>/dev/null | head -1 || echo 'Chưa cài')"
echo "✅ Profile: $(eselect profile show)"

# 8. CÀI THÊM CÁC GÓI QUAN TRỌNG
echo "8. Cài thêm các gói quan trọng..."
emerge --oneshot sys-devel/autoconf sys-devel/automake sys-devel/libtool

echo "========================================"
echo "🎉 FIX HOÀN TẤT! Hệ thống Portage đã sẵn sàng."
echo "Tiếp tục cài đặt các gói khác..."