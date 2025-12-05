# Dòng 129-134
cat >> /etc/portage/package.use/hyprland << 'EOF'
gui-wm/hyprland -systemd
x11-terms/kitty -wayland
EOF
