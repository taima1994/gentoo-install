# Mask systemd
echo "sys-apps/systemd" >> /etc/portage/package.mask
echo "virtual/systemd" >> /etc/portage/package.mask

# Cấu hình use flags
echo "sys-apps/dbus -systemd elogind" >> /etc/portage/package.use
echo "sys-apps/util-linux -systemd" >> /etc/portage/package.use
echo "virtual/libudev -systemd" >> /etc/portage/package.use

# Update với --autounmask
emerge --update --deep --newuse @world --autounmask-write
dispatch-conf