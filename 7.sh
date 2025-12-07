# 7. Cài Hyprland + theme Ghost
echo "7. Cài Hyprland..."
cat >> /etc/portage/package.use/hyprland << 'EOF'
gui-wm/hyprland -systemd
x11-terms/kitty -wayland
EOF
emerge gui-wm/hyprland x11-terms/kitty waybar wofi mako rofi-lbonn-wayland
