cat > fix-hyprland.sh << 'EOF'
#!/bin/bash
echo "=== KHẮC PHỤC HYPRLAND KHÔNG MỞ ĐƯỢC TERMINAL ==="

# 1. Tạo config cơ bản
mkdir -p ~/.config/hypr
cat > ~/.config/hypr/hyprland.conf << 'CONFIG'
# Monitor
monitor=,preferred,auto,1

# Autostart
exec-once = kitty
exec-once = waybar
exec-once = nm-applet

# Keybinds
$mainMod = SUPER
bind = $mainMod, RETURN, exec, kitty
bind = $mainMod, T, exec, foot
bind = $mainMod, E, exec, nemo
bind = $mainMod, Q, killactive
bind = $mainMod, F, fullscreen
bind = $mainMod, D, exec, rofi -show drun
CONFIG

# 2. Đảm bảo có terminal
echo "Đang kiểm tra terminal..."
TERMINALS=("kitty" "foot" "alacritty" "gnome-terminal" "xfce4-terminal")
for term in "${TERMINALS[@]}"; do
    if which $term &>/dev/null; then
        echo "✓ Terminal $term có sẵn"
        # Sử dụng terminal đầu tiên tìm thấy
        sed -i "s/exec, kitty/exec, $term/" ~/.config/hypr/hyprland.conf
        break
    fi
done

# 3. Tạo desktop entry cho SDDM
sudo tee /usr/share/wayland-sessions/hyprland.desktop << 'DESKTOP'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
DESKTOP

# 4. Restart display manager
echo "Restarting SDDM..."
sudo systemctl restart sddm

echo "✅ Đã khắc phục. Hãy logout và login lại."
echo "Phím tắt mới:"
echo "  • Super+Enter: Mở terminal"
echo "  • Super+T: Mở terminal dự phòng"
echo "  • Super+E: File manager"
echo "  • Super+D: App launcher"
EOF

chmod +x fix-hyprland.sh
./fix-hyprland.sh