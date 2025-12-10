#!/bin/bash
echo "=== SPRIT 5: AUTO UPDATE & LOCALE ==="

# 5.1 Update @world với YES mặc định
echo "Updating @world (this will take hours)..."
ACCEPT_KEYWORDS="*" ACCEPT_LICENSE="*" emerge --verbose --update --deep --newuse @world

# 5.2 Auto timezone
echo "Setting timezone to Asia/Ho_Chi_Minh..."
echo "Asia/Ho_Chi_Minh" > /etc/timezone
emerge --config sys-libs/timezone-data --quiet

# 5.3 Auto locale
echo "Configuring locale..."
# Tự động uncomment en_US.UTF-8
sed -i '/en_US.UTF-8/s/^#//g' /etc/locale.gen
sed -i '/vi_VN/s/^#//g' /etc/locale.gen  # Optional

locale-gen

# Tự động chọn en_US.utf8 (không cần nhớ số)
LOCALE_NUM=$(eselect locale list | grep "en_US.utf8" | grep -o "\[[0-9]*\]" | tr -d '[]')
if [ ! -z "$LOCALE_NUM" ]; then
    eselect locale set $LOCALE_NUM
else
    # Fallback: chọn cái đầu tiên
    eselect locale set 1
fi

env-update
source /etc/profile

echo "=== SPRIT 5 COMPLETE ==="
