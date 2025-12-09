# 5.1 Cập nhật hệ thống
emerge --ask --verbose --update --deep --newuse @world

# 5.2 Cấu hình timezone
echo "Asia/Ho_Chi_Minh" > /etc/timezone
emerge --config sys-libs/timezone-data

# 5.3 Cấu hình locale
nano /etc/locale.gen
# Bỏ comment dòng: en_US.UTF-8 UTF-8
# Và: vi_VN UTF-8 (nếu muốn)

locale-gen

eselect locale list
eselect locale set [SỐ_CỦA_en_US.utf8]

env-update
source /etc/profile
