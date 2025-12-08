#!/bin/bash
# ==============================================================================
# GHOST GENTOO - BOOTSTRAP SCRIPT
# Tải toàn bộ repository từ GitHub
# ==============================================================================

set -e

# ==============================================================================
# CẤU HÌNH
# ==============================================================================
REPO_URL="https://github.com/taima1994/gentoo-install"
REPO_NAME="gentoo-install"
REPO_DIR="$PWD/$REPO_NAME"

# ==============================================================================
# KIỂM TRA
# ==============================================================================
echo "========================================"
echo "GHOST GENTOO - BOOTSTRAP SCRIPT"
echo "========================================"

# Kiểm tra quyền root
if [[ $EUID -ne 0 ]]; then
    echo "⚠️  Cần chạy với quyền root: sudo bash bootstrap.sh"
    echo "   Hoặc: sudo ./bootstrap.sh"
    exit 1
fi

# Kiểm tra nếu đã có repository
if [ -f "ghost-install.sh" ]; then
    echo "✅ Repository đã tồn tại trong thư mục hiện tại."
    echo ""
    echo "Bạn có thể chạy:"
    echo "  chmod +x ghost-install.sh"
    echo "  sudo ./ghost-install.sh"
    exit 0
fi

# ==============================================================================
# KIỂM TRA CÔNG CỤ CẦN THIẾT
# ==============================================================================
echo "🔍 Kiểm tra công cụ cần thiết..."

# Kiểm tra wget
if ! command -v wget &> /dev/null; then
    echo "❌ wget không được tìm thấy."
    echo "   Cài đặt:"
    echo "   - Ubuntu/Debian: sudo apt install wget"
    echo "   - Arch: sudo pacman -S wget"
    echo "   - Fedora: sudo dnf install wget"
    exit 1
fi

# Kiểm tra tar
if ! command -v tar &> /dev/null; then
    echo "❌ tar không được tìm thấy."
    echo "   Cài đặt:"
    echo "   - Ubuntu/Debian: sudo apt install tar"
    echo "   - Arch: sudo pacman -S tar"
    echo "   - Fedora: sudo dnf install tar"
    exit 1
fi

# ==============================================================================
# TẢI REPOSITORY TỪ GITHUB
# ==============================================================================
echo ""
echo "⬇️  Đang tải repository từ GitHub..."

# Tạo thư mục tạm
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Tải repository dưới dạng tar.gz
echo "   → Tải file nén từ GitHub..."
wget -q --show-progress "$REPO_URL/archive/main.tar.gz" -O repo.tar.gz

# Giải nén
echo "   → Giải nén..."
tar xzf repo.tar.gz

# Di chuyển file về thư mục hiện tại
echo "   → Di chuyển file..."
mv "$REPO_NAME-main"/* "$REPO_NAME-main"/.* 2>/dev/null || true
cd "$REPO_NAME-main"
cp -r . "$REPO_DIR" 2>/dev/null || cp -r * "$REPO_DIR"

# Dọn dẹp
cd /
rm -rf "$TEMP_DIR"

# ==============================================================================
# KIỂM TRA FILE ĐÃ TẢI
# ==============================================================================
echo ""
echo "📂 Kiểm tra file đã tải..."

if [ -f "$REPO_DIR/ghost-install.sh" ]; then
    echo "✅ ghost-install.sh - OK"
else
    echo "❌ ghost-install.sh - KHÔNG TÌM THẤY"
    exit 1
fi

if [ -f "$REPO_DIR/README.md" ]; then
    echo "✅ README.md - OK"
fi

if [ -d "$REPO_DIR/configs" ]; then
    echo "✅ configs/ - OK"
fi

# ==============================================================================
# CẤP QUYỀN THỰC THI
# ==============================================================================
echo ""
echo "🔧 Cấp quyền thực thi..."
chmod +x "$REPO_DIR/ghost-install.sh"

# ==============================================================================
# HOÀN TẤT
# ==============================================================================
echo ""
echo "========================================"
echo "✅ TẢI THÀNH CÔNG!"
echo "========================================"
echo ""
echo "📁 Repository đã được tải về tại:"
echo "   $REPO_DIR"
echo ""
echo "📋 Các file đã tải:"
ls -la "$REPO_DIR"
echo ""
echo "🚀 ĐỂ BẮT ĐẦU CÀI ĐẶT:"
echo "   cd $REPO_NAME"
echo "   sudo ./ghost-install.sh"
echo ""
echo "📖 ĐỂ XEM HƯỚNG DẪN:"
echo "   cat README.md"
echo ""
echo "========================================"

# Tạo shortcut
ln -sf "$REPO_DIR/ghost-install.sh" ./ghost-install.sh 2>/dev/null || true

echo "💡 Lời khuyên:"
echo "   1. Đọc kỹ README.md trước khi cài đặt"
echo "   2. Backup dữ liệu quan trọng"
echo "   3. Đảm bảo kết nối mạng ổn định"
echo "========================================"
