# Kiểm tra Hyprland đã cài chưa
which hyprctl

# Tạo thư mục config nếu chưa có
mkdir -p ~/.config/hypr

# Tạo file config tối thiểu
cat > ~/.config/hypr/hyprland.conf << 'EOF'
# Monitor
monitor=,preferred,auto,1

# Autostart - QUAN TRỌNG: thêm terminal vào đây
exec-once = kitty
exec-once = waybar
exec-once = nm-applet --indicator

# Input
input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = no
    }
}

# General
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(89b4faee)
    col.inactive_border = rgba(313244aa)
}

# Keybindings - QUAN TRỌNG: phải đúng cú pháp
$mainMod = SUPER

# Terminal - THÊM 2 PHÍM TẮT CHO CHẮC
bind = $mainMod, RETURN, exec, kitty
bind = $mainMod, T, exec, foot
bind = $mainMod, A, exec, alacritty

# Applications
bind = $mainMod, Q, killactive
bind = $mainMod, E, exec, nemo
bind = $mainMod, D, exec, rofi -show drun
bind = $mainMod, F, fullscreen

# System
bind = $mainMod SHIFT, Q, exit
bind = $mainMod SHIFT, R, exec, hyprctl reload
bind = $mainMod, L, exec, swaylock

# Window focus
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3

# Mouse
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
EOF