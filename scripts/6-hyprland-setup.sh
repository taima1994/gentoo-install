k#!/bin/bash
set -e
echo "6. CÀI ĐẶT HYPRLAND + DESKTOP + AUTO LOGIN"

# Thêm USE flags cho wayland
mkdir -p /etc/portage/package.use
cat > /etc/portage/package.use/hyprland << 'EOF'
gui-wm/hyprland wayland X
gui-libs/wlroots X
x11-terms/kitty wayland
gui-apps/waybar tray
EOF

# Cài đặt desktop
emerge --quiet-build gui-wm/hyprland \
  x11-terms/kitty \
  gui-apps/waybar \
  gui-apps/wofi \
  gui-apps/mako \
  gui-apps/swaylock \
  media-sound/pulseaudio \
  x11-misc/xdg-utils \
  sys-apps/dbus \
  sys-apps/elogind

# Tạo user ghost với auto login
useradd -m -G wheel,audio,video,portage -s /bin/bash ghost
echo "ghost:ghost" | chpasswd

# Cấu hình sudo không cần password cho ghost (auto login)
emerge app-admin/sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo "ghost ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/ghost

# Tạo auto login cho TTY1 (không cần mật khẩu sau khi reboot)
mkdir -p /etc/elogind
cat > /etc/elogind/logind.conf << 'EOF'
[Login]
NAutoVTs=6
ReserveVT=6
KillUserProcesses=no
KillOnlyUsers=
KillExcludeUsers=root
InhibitDelayMaxSec=5
HandlePowerKey=poweroff
HandleSuspendKey=suspend
HandleHibernateKey=hibernate
HandleLidSwitch=suspend
EOF

# Tạo service tự động khởi động Hyprland
cat > /etc/local.d/autostart.start << 'EOF'
#!/bin/bash
# Tự động login user ghost vào tty1 và start Hyprland
if [[ "$(tty)" == "/dev/tty1" ]]; then
    sleep 1
    echo "Auto-login as ghost..."
    sudo -u ghost dbus-run-session Hyprland
fi
EOF

chmod +x /etc/local.d/autostart.start

# Tạo cấu hình Hyprland mặc định
mkdir -p /home/ghost/.config/hypr
cat > /home/ghost/.config/hypr/hyprland.conf << 'EOF'
# GHOST 2025 - Auto Hyprland Config
monitor=,preferred,auto,1

exec-once = waybar
exec-once = mako
exec-once = /usr/libexec/polkit-gnome-authentication-agent-1
exec-once = nm-applet --indicator

input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = no
    }
}

general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
}

decoration {
    rounding = 10
    blur = yes
    blur_size = 3
    blur_passes = 1
}

animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = fade, 1, 7, default
}

bind = SUPER, RETURN, exec, kitty
bind = SUPER, Q, killactive,
bind = SUPER, M, exit,
bind = SUPER, V, togglefloating,
bind = SUPER, F, fullscreen,
bind = SUPER, E, exec, thunar
bind = SUPER, SPACE, exec, wofi --show drun
bind = SUPER, P, exec, grim -g "$(slurp)" - | wl-copy
bind = , Print, exec, grim - | wl-copy
EOF

chown -R ghost:ghost /home/ghost

echo "HYPRLAND + AUTO LOGIN XONG!"
