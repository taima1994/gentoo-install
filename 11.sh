# 11.1 Login với user mới

# 11.2 Kiểm tra hệ thống
uname -a
df -h
free -h

# 11.3 Cập nhật hệ thống lần cuối
sudo emerge --sync
sudo emerge --ask --verbose --update --deep --newuse @world

# 11.4 Dọn dẹp
sudo emerge --depclean
sudo eselect news read all
