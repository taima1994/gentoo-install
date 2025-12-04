# GHOST 2025 – Gentoo Full Install Scripts (Hardened + SELinux + Hyprland + Catalyst)

## ĐẶC ĐIỂM
- Kernel Hardened với SELinux
- Desktop Environment: Hyprland (Wayland)
- Build system tối ưu: Catalyst + IceCC + CCache
- Phân vùng tối ưu cho SSD/HDD
- Mirror tốc độ cao cho Việt Nam
- **Auto Login 100%**: Tự động đăng nhập user `ghost` và khởi động Hyprland

## YÊU CẦU HỆ THỐNG
- Ổ SSD (sda) tối thiểu 250GB (cho root và home)
- Ổ HDD (sdb) cho build cache (/var/tmp/portage)
- RAM tối thiểu 8GB, khuyến nghị 16GB+
- CPU đa nhân (càng nhiều core càng tốt)

## CÁCH CÀI ĐẶT
### Từ Gentoo Minimal LiveCD:
```bash
# 1. Kết nối internet (nếu dùng WiFi)
iwctl station wlan0 connect "TEN_WIFI"
# hoặc với cable Ethernet sẽ tự động

# 2. Chạy 1 lệnh duy nhất
wget -qO- https://raw.githubusercontent.com/taima1994/gentoo-install/main/bootstrap.sh | bash
