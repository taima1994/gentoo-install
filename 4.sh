# 4.4 Mount boot partition trong chroot
mount /dev/sda1 /boot

# 4.5 Cập nhật portage tree
emerge-webrsync

# 4.6 Chọn profile
eselect profile list
# Chọn profile (VD: default/linux/amd64/17.1/desktop)
eselect profile set [NUMBER]
