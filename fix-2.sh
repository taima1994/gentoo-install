# ========================================
# FIX NHANH LỖI "NO EBUILDS" TRONG CHROOT
# ========================================

# 1. DI CHUYỂN PORTAGE TREE VỀ ĐÚNG VỊ TRÍ
echo "🔄 Di chuyển Portage tree về đúng vị trí..."
mkdir -p /var/db/repos/gentoo
# Nếu có ở /usr/portage, di chuyển
if [ -d "/usr/portage" ]; then
    mv /usr/portage/* /var/db/repos/gentoo/ 2>/dev/null || true
    rm -rf /usr/portage
fi

# 2. KIỂM TRA PORTAGE TREE
echo "📂 Kiểm tra Portage tree..."
if [ ! -f "/var/db/repos/gentoo/profiles/repo_name" ]; then
    echo "⚠️  Portage tree trống, tải lại..."
    cd /var/db/repos/gentoo
    wget -q https://mirror.meowsmp.net/gentoo/snapshots/portage-latest.tar.xz
    tar xpf portage-latest.tar.xz --strip-components=1
    rm -f portage-latest.tar.xz
fi

# 3. CHỌN PROFILE ĐÚNG
echo "🎯 Chọn profile hệ thống..."
eselect profile list
# Chọn profile đầu tiên (thường là default/linux/amd64/17.1)
eselect profile set 1

# 4. CẬP NHẬT MÔI TRƯỜNG
echo "⚡ Cập nhật môi trường..."
env-update && source /etc/profile

# 5. CÀI MAKE BẰNG TAY (NẾU CẦN)
echo "🔧 Cài đặt make và các công cụ cơ bản..."
# Thử cài từ binary trước
emerge --usepkg sys-devel/make 2>/dev/null || \
emerge --oneshot sys-devel/make

# 6. KIỂM TRA
echo "✅ Kiểm tra..."
which make && make --version
echo "Portage tree: $(ls -d /var/db/repos/gentoo/* | wc -l) ebuilds"