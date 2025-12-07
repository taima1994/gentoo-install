#!/bin/bash
set -e
echo "GHOST 2025 - GENTOO INSTALL"
echo "Tải và chạy installer..."
# 1. Tải script
wget https://raw.githubusercontent.com/taima1994/gentoo-install/main/bootstrap.sh

# 2. Cấp quyền thực thi
chmod +x bootstrap.sh

# 3. Chạy với quyền root
sudo ./bootstrap.sh
