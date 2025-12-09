# 1.1 Boot từ USB/LiveCD
# Chọn option boot phù hợp với UEFI/Legacy

# 1.2 Kiểm tra kết nối mạng
ping -c 3 google.com

# 1.3 Nếu dùng WiFi
iwctl
# Trong iwctl:
station wlan0 scan
station wlan0 get-networks
station wlan0 connect [SSID]
# Nhập password nếu có

# 1.4 Kiểm tra lại
ip addr show
ping -c 3 gentoo.org

# 1.5 Cập nhật date/time
date
# Nếu sai:
ntpd -q -g
