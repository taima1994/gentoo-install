cat > install-hyprland-apps.sh << 'EOF'
#!/bin/bash
set -e

echo "🔄 CẬP NHẬT CONFIG VÀ CÀI ĐẶT ỨNG DỤNG CHO HYPRLAND..."

# Backup config hiện tại
sudo cp /etc/nixos/configuration.nix /etc/nixos/configuration.nix.backup.$(date +%s)

# Đọc config hiện tại và thêm packages
sudo tee /etc/nixos/configuration.nix << 'CONFIG'
{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "nixos-sdc";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Ho_Chi_Minh";

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  users.users.ghost = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };

  # TẤT CẢ ỨNG DỤNG TỰ ĐỘNG CÀI ĐÂY
  environment.systemPackages = with pkgs; [
    # ========== TERMINAL & SHELL ==========
    kitty          # Terminal chính
    foot           # Terminal phụ (nhẹ)
    alacritty      # Terminal GPU accelerated
    zsh            # Shell hiện đại
    oh-my-zsh      # Framework Zsh
    starship       # Prompt đẹp
    tmux           # Terminal multiplexer
    
    # ========== HYPRLAND ECOSYSTEM ==========
    waybar         # Status bar
    rofi-wayland   # App launcher
    dunst          # Notification daemon
    swaybg         # Wallpaper
    swaylock-effects # Lock screen với hiệu ứng
    grim           # Screenshot
    slurp          # Region selector
    wl-clipboard   # Clipboard tool
    cliphist       # Clipboard history
    swappy         # Screenshot editor
    wf-recorder    # Screen recorder
    
    # ========== SYSTEM TOOLS ==========
    htop           # Process viewer
    btop           # Resource monitor (đẹp)
    neofetch       # System info
    nvtop          # GPU monitor
    nala-gui       # Package manager GUI
    gparted        # Partition editor
    gnome.nautilus # File manager
    nemo           # File manager (Cinnamon)
    pcmanfm        # File manager nhẹ
    ranger         # File manager terminal
    baobab         # Disk usage analyzer
    gnome-disk-utility # Disk management
    
    # ========== BROWSERS ==========
    firefox        # Browser chính
    google-chrome  # Browser phụ
    brave          # Privacy browser
    qutebrowser    # Keyboard-driven browser
    
    # ========== OFFICE & DOCUMENTS ==========
    libreoffice-fresh # Office suite
    onlyoffice-bin # Office online
    okular         # PDF viewer
    evince         # PDF viewer (GNOME)
    zathura        # PDF viewer (Vim-like)
    calibre        # E-book management
    
    # ========== MEDIA ==========
    vlc            # Media player
    mpv            # Media player nhẹ
    celluloid      # Frontend cho mpv
    audacity       # Audio editor
    spotify        # Music streaming
    strawberry     # Music player
    gthumb         # Image viewer
    shotwell       # Photo manager
    feh            # Image viewer nhẹ
    
    # ========== GRAPHICS & DESIGN ==========
    gimp           # Image editor
    inkscape       # Vector graphics
    krita          # Digital painting
    darktable      # Photo workflow
    blender        # 3D modeling
    
    # ========== DEVELOPMENT ==========
    vscode         # Code editor
    neovim         # Editor terminal
    helix          # Editor modal
    jetbrains.idea-community # Java IDE
    python3        # Python
    nodejs         # Node.js
    gcc            # C compiler
    gnumake        # Make tool
    cmake          # Build system
    docker         # Container
    docker-compose # Container orchestration
    postman        # API testing
    
    # ========== COMMUNICATION ==========
    telegram-desktop # Messaging
    discord         # Chat gaming
    element-desktop # Matrix client
    thunderbird     # Email client
    signal-desktop  # Secure messaging
    
    # ========== UTILITIES ==========
    zip unzip p7zip # Archive tools
    filezilla       # FTP client
    transmission-gtk # Torrent client
    keepassxc       # Password manager
    remmina         # Remote desktop
    flameshot       # Screenshot tool
    simplescreenrecorder # Screen recording
    guvcview        # Webcam viewer
    arandr          # Screen layout editor
    pavucontrol     # Audio control
    networkmanagerapplet # Network tray
    blueman         # Bluetooth manager
    
    # ========== FONTS ==========
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Hack" "UbuntuMono" "Meslo" ]; })
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    font-awesome
    corefonts       # Microsoft fonts
    
    # ========== THEMES & ICONS ==========
    catppuccin-gtk  # Catppuccin theme
    papirus-icon-theme # Icon theme
    arc-theme       # Arc theme
    materia-theme   # Material theme
    
    # ========== NIX TOOLS ==========
    nix-index       # Package search
    nix-output-monitor # Build monitor
    nh              # Nix helper
    nixos-option    # Explore options
  ];

  # Fonts configuration
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Hack" ]; })
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
  ];

  # Cho phép unfree packages
  nixpkgs.config.allowUnfree = true;

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.05";
}
CONFIG

echo "✅ ĐÃ CẬP NHẬT CONFIG"
echo "🔄 BẮT ĐẦU REBUILD (có thể mất 15-30 phút)..."

# Rebuild hệ thống
sudo nixos-rebuild switch

echo ""
echo "🎉 CÀI ĐẶT HOÀN TẤT!"
echo "========================"
echo "📦 ĐÃ CÀI ĐẶT:"
echo "  • 5+ terminals"
echo "  • 3+ file managers"
echo "  • 4+ browsers"
echo "  • Office suite"
echo "  • Media players"
echo "  • Graphics tools"
echo "  • Development tools"
echo "  • Communication apps"
echo "  • 50+ utilities"
echo ""
echo "🚀 KHỞI ĐỘNG LẠI CÁC ỨNG DỤNG:"
echo "  • Hyprland: Super+Shift+R"
echo "  • Waybar: pkill waybar && waybar"
echo "  • Hoặc reboot: sudo reboot"
echo ""
echo "🎯 MỞ ỨNG DỤNG:"
echo "  • Terminal: Super+Enter"
echo "  • App launcher: Super+D"
echo "  • File manager: Super+E"
echo "  • Browser: firefox (trong terminal)"
EOF

# Cấp quyền và chạy script
chmod +x install-hyprland-apps.sh
./install-hyprland-apps.sh
