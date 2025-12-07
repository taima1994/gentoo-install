cat > /etc/portage/package.use/avoid-systemd << 'EOF'
sys-apps/dbus -systemd
sys-apps/util-linux -systemd
virtual/libudev -systemd
sec-policy/selinux-base-policy -systemd
EOF