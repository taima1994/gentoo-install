#!/bin/bash
set -e
echo "GHOST 2025 - GENTOO INSTALL"
echo "Tải và chạy installer..."
# 1. Tải script
wget https://raw.githubusercontent.com/taima1994/gentoo-install/main/ghost-installer-full.sh
wget https://raw.githubusercontent.com/taima1994/gentoo-install/main/fix-3.sh

# 2. Cấp quyền thực thi
chmod +x ghost-installer-full.sh

