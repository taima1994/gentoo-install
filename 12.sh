# 12. Timezone + locale
echo "Asia/Ho_Chi_Minh" > /etc/timezone
emerge --config sys-libs/timezone-data
echo "vi_VN.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale set vi_VN.utf8
env-update && source /etc/profile
