cat > setup-hyprland-config.sh << 'EOF'
#!/bin/bash

echo "🎨 TẠO CONFIG HYPRLAND & DOTFILES..."

# Tạo thư mục config
mkdir -p ~/.config/{hypr,waybar,rofi,kitty}

# 1. Hyprland config
cat > ~/.config/hypr/hyprland.conf << 'HYPR'
# Monitor setup
monitor=,preferred,auto,1

# Autostart
exec-once = waybar
exec-once = dunst
exec-once = swaybg -i ~/Pictures/wallpaper.jpg
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = nm-applet --indicator
exec-once = blueman-applet
exec-once = wl-paste --watch cliphist store

# Input
input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = no
    }
    sensitivity = 0
}

# General
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(89b4faee)
    col.inactive_border = rgba(313244aa)
    layout = dwindle
}

# Decoration
decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 1
    }
    drop_shadow = yes
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

# Animations
animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = fade, 1, 7, default
}

# Keybindings
$mainMod = SUPER

# Applications
bind = $mainMod, RETURN, exec, kitty
bind = $mainMod, Q, killactive
bind = $mainMod, F, fullscreen
bind = $mainMod, E, exec, nemo
bind = $mainMod, D, exec, rofi -show drun
bind = $mainMod, P, pseudo

# Screenshot
bind = , PRINT, exec, grim -g "\$(slurp)" - | wl-copy
bind = SHIFT, PRINT, exec, grim -g "\$(slurp)" ~/Pictures/Screenshots/\$(date +'%Y-%m-%d-%H%M%S').png

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
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5

# Move window to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5

# Special workspace (scratchpad)
bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod SHIFT, S, movetoworkspace, special:magic
HYPR

# 2. Waybar config
cat > ~/.config/waybar/config << 'WAYBAR'
{
  "layer": "top",
  "position": "top",
  "height": 30,
  "modules-left": ["hyprland/workspaces", "hyprland/window"],
  "modules-center": ["clock"],
  "modules-right": ["pulseaudio", "network", "battery", "tray"],
  "clock": {
    "format": "{:%H:%M  %d/%m/%Y}",
    "tooltip-format": "{:%A, %B %d, %Y}"
  },
  "pulseaudio": {
    "format": "{volume}% {icon}",
    "format-muted": "",
    "format-icons": ["", "", ""]
  },
  "network": {
    "format-wifi": "  {essid}",
    "format-ethernet": "  {ifname}",
    "format-disconnected": "⚠  Disconnected"
  }
}
WAYBAR

# 3. Rofi config
cat > ~/.config/rofi/config.rasi << 'ROFI'
configuration {
  modi: "drun,run,window";
  show-icons: true;
  icon-theme: "Papirus-Dark";
  terminal: "kitty";
}
ROFI

# 4. Kitty config
cat > ~/.config/kitty/kitty.conf << 'KITTY'
font_family      JetBrainsMono Nerd Font
font_size        12
background_opacity 0.9

# Colors (Catppuccin Mocha)
foreground       #cdd6f4
background       #1e1e2e
selection_foreground #1e1e2e
selection_background #f5e0dc

color0 #45475a
color1 #f38ba8
color2 #a6e3a1
color3 #f9e2af
color4 #89b4fa
color5 #f5c2e7
color6 #94e2d5
color7 #bac2de
color8 #585b70
color9 #f38ba8
color10 #a6e3a1
color11 #f9e2af
color12 #89b4fa
color13 #f5c2e7
color14 #94e2d5
color15 #a6adc8
KITTY

# 5. Tạo aliases và shell config
cat > ~/.bash_aliases << 'ALIASES'
# System
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# NixOS
alias update='sudo nixos-rebuild switch --upgrade'
alias clean='sudo nix-collect-garbage -d'
alias nixsearch='nix search nixos'
alias rebuild='sudo nixos-rebuild switch'
alias rollback='sudo nixos-rebuild switch --rollback'

# Hyprland
alias hyprlog='tail -f ~/.local/share/hyprland/hyprland.log'
alias hyprconf='nvim ~/.config/hypr/hyprland.conf'
alias hyprreload='hyprctl reload'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'

# Utilities
alias htop='btop'
alias cat='bat'
alias ls='eza --icons'
ALIASES

echo "source ~/.bash_aliases" >> ~/.bashrc

# 6. Tạo thư mục cần thiết
mkdir -p ~/Pictures/{Wallpapers,Screenshots}
mkdir -p ~/Documents/{Work,Projects,Downloads}

# 7. Download wallpaper mẫu
curl -s -o ~/Pictures/wallpaper.jpg https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=1920&h=1080&fit=crop

echo ""
echo "✅ ĐÃ TẠO CONFIG HOÀN CHỈNH!"
echo "==============================="
echo "🎨 ĐÃ CÀI ĐẶT:"
echo "  • Hyprland config với keybinds"
echo "  • Waybar với modules"
echo "  • Rofi app launcher"
echo "  • Kitty terminal theme"
echo "  • Shell aliases tiện ích"
echo "  • Wallpaper mẫu"
echo ""
echo "🔄 RELOAD HYPRLAND: Super+Shift+R"
echo "📁 THƯ MỤC ĐÃ TẠO:"
echo "  ~/.config/hypr/"
echo "  ~/.config/waybar/"
echo "  ~/.config/rofi/"
echo "  ~/.config/kitty/"
echo "  ~/Pictures/Wallpapers/"
EOF

chmod +x setup-hyprland-config.sh
./setup-hyprland-config.sh
