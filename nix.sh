#!/bin/bash
set -e

echo "=== PHÂN VÙNG VÀ FORMAT SD CARD ==="
sudo wipefs -a /dev/sdc
sudo parted /dev/sdc -- mklabel gpt
sudo parted /dev/sdc -- mkpart primary fat32 1MiB 1GiB
sudo parted /dev/sdc -- set 1 esp on
sudo parted /dev/sdc -- mkpart primary ext4 1GiB 100%

echo "=== FORMAT FILESYSTEM ==="
sudo mkfs.fat -F 32 -n BOOT /dev/sdc1
sudo mkfs.ext4 -L NIXOS /dev/sdc2

echo "=== MOUNT PHÂN VÙNG ==="
sudo mount /dev/sdc2 /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/sdc1 /mnt/boot

sudo mkdir -p /mnt/etc

echo "=== CLONE REPO ==="
cd /mnt/etc
sudo rm -rf nixos
sudo git clone --depth 1 https://github.com/JaKooLit/NixOS-Hyprland nixos
cd nixos

echo "=== TẠO CẤU HÌNH HOST ==="
sudo mkdir -p hosts/sdcard
sudo cp -r hosts/default/* hosts/sdcard/

# Tạo variables.nix đầy đủ
sudo tee hosts/sdcard/variables.nix << 'EOF'
{
  username = "ghost";
  hostname = "nixos-sdc";
  theme = "catppuccin-mocha";
  browser = "firefox";
  defaultTerminal = "kitty";
  editor = "helix";
  wallpaper = "~/Wallpapers/nixos.png";
  keyboardLayout = "us";
  timezone = "Asia/Ho_Chi_Minh";
  
  # Thêm các package mong muốn
  additionalPackages = [
    "nala-gui"
    "btop"
    "nemo"
    "vscode"
    "libreoffice-fresh"
    "vlc"
    "firefox"
    "google-chrome"
    "hyprland"
    "waybar"
    "rofi-wayland"
    "dunst"
    "swaybg"
    "swaylock"
    "grim"
    "slurp"
    "wl-clipboard"
    "networkmanagerapplet"
    "blueman"
    "pavucontrol"
    "gparted"
    "neofetch"
    "htop"
    "git"
    "curl"
    "wget"
    "zip"
    "unzip"
  ];
}
EOF

# Tạo config.nix đầy đủ với tất cả package và cấu hình
sudo tee hosts/sdcard/config.nix << 'EOF'
{ config, lib, pkgs, inputs, ... }:
let
  vars = import ./variables.nix;
in
{
  imports = [ ./hardware.nix ./variables.nix ];

  # Bootloader cho SD card
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = false;
    grub.useOSProber = true;
  };

  # Network
  networking.hostName = vars.hostname;
  networking.networkmanager.enable = true;

  # Timezone và Locale
  time.timeZone = vars.timezone;
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "vi_VN.UTF-8";
    LC_IDENTIFICATION = "vi_VN.UTF-8";
    LC_MEASUREMENT = "vi_VN.UTF-8";
    LC_MONETARY = "vi_VN.UTF-8";
    LC_NAME = "vi_VN.UTF-8";
    LC_NUMERIC = "vi_VN.UTF-8";
    LC_PAPER = "vi_VN.UTF-8";
    LC_TELEPHONE = "vi_VN.UTF-8";
    LC_TIME = "vi_VN.UTF-8";
  };

  # Console
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    enableNvidiaPatches = lib.mkDefault false;
  };

  # Display Manager
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha";
  };

  # Audio với PipeWire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # User
  users.users.${vars.username} = {
    isNormalUser = true;
    description = "Ghost User";
    extraGroups = [ 
      "wheel" 
      "networkmanager" 
      "video" 
      "audio" 
      "storage" 
      "lp" 
      "scanner" 
      "kvm" 
      "libvirtd" 
      "docker" 
    ];
    initialPassword = "password123";
    packages = with pkgs; [
      # Terminal và tools
      kitty
      foot
      alacritty
      tmux
      ranger
      
      # File managers
      nemo
      gnome.nautilus
      pcmanfm
      
      # System tools
      btop
      htop
      neofetch
      nvtop
      nala-gui
      gparted
      gnome.gnome-disk-utility
      
      # Browsers
      firefox
      google-chrome
      brave
      
      # Office
      libreoffice-fresh
      onlyoffice-bin
      okular
      
      # Media
      vlc
      mpv
      celluloid
      audacity
      
      # Graphics
      gimp
      inkscape
      krita
      
      # Development
      vscode
      jetbrains.idea-community
      neovim
      helix
      
      # Communication
      telegram-desktop
      discord
      element-desktop
      
      # Utilities
      zip
      unzip
      p7zip
      filezilla
      transmission-gtk
      remmina
      keepassxc
      
      # Hyprland ecosystem
      waybar
      rofi-wayland
      dunst
      swaybg
      swaylock-effects
      grim
      slurp
      wl-clipboard
      cliphist
      
      # Fonts
      (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Hack" "UbuntuMono" ]; })
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      font-awesome
      
      # Thêm tất cả package từ variables.nix
    ] ++ map (pkgName: pkgs.${pkgName}) vars.additionalPackages;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # System management
    nix-index
    nix-output-monitor
    nh
    nixos-option
    
    # Command line tools
    bat
    eza
    fd
    ripgrep
    fzf
    jq
    yq
    duf
    du-dust
    procs
    bottom
    
    # Network
    nmap
    wireshark
    netcat
    openssl
    
    # Security
    gnupg
    pass
    age
    sops
    
    # Virtualization
    qemu
    virt-manager
    docker
    docker-compose
  ];

  # Fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Hack" "UbuntuMono" "Meslo" ]; })
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    font-awesome
    corefonts
    dejavu_fonts
    freefont_ttf
    gyre-fonts
    liberation_ttf
  ];

  # Nix settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      builders-use-substitutes = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };
    
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
    
    extraOptions = ''
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}
    '';
  };

  # Cho phép unfree và broken packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # Security
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;  # Tiện cho SD card

  # Services
  services = {
    printing.enable = true;
    avahi = {
      enable = true;
      nssmdns = true;
    };
    openssh.enable = true;
    tailscale.enable = true;
    flatpak.enable = true;
  };

  # Virtualization
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
    podman.enable = true;
  };

  system.stateVersion = "25.05";

  # Tự động clean và upgrade sau khi cài
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
    allowReboot = false;
    flake = "/etc/nixos#sdcard";
  };
}
EOF

# Tạo cấu hình Home Manager để quản lý dotfiles
echo "=== TẠO CẤU HÌNH HOME MANAGER ==="
sudo tee hosts/sdcard/home.nix << 'EOF'
{ config, pkgs, lib, ... }:

{
  home.username = "ghost";
  home.homeDirectory = "/home/ghost";
  home.stateVersion = "25.05";

  # Cấu hình Git
  programs.git = {
    enable = true;
    userName = "Ghost User";
    userEmail = "ghost@localhost";
    aliases = {
      co = "checkout";
      ci = "commit";
      st = "status";
      br = "branch";
      hist = "log --pretty=format:'%C(yellow)%h %C(red)%d %C(reset)%s %C(green)[%an] %C(cyan)%ad' --topo-order --graph --date=short";
      type = "cat-file -t";
      dump = "cat-file -p";
    };
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };

  # Shell configuration
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "eza -la --icons --git";
      ls = "eza --icons";
      lt = "eza --tree --icons";
      cat = "bat";
      grep = "rg";
      find = "fd";
      du = "duf";
      df = "duf";
      ps = "procs";
      top = "btop";
      nrs = "sudo nixos-rebuild switch --flake /etc/nixos#sdcard";
      nru = "sudo nixos-rebuild switch --flake /etc/nixos#sdcard --upgrade";
      nrg = "sudo nix-collect-garbage -d";
      nrh = "sudo nixos-rebuild switch --flake /etc/nixos#sdcard --rollback";
      ns = "nix search nixos";
      nsh = "nix shell nixpkgs#";
      nixpkgs = "cd /etc/nixos && sudo nix flake update";
      update = "sudo nixos-rebuild switch --upgrade && sudo nix-collect-garbage -d";
      clean = "sudo nix-collect-garbage -d && sudo nix-store --optimise";
      gen = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
    };
    initExtra = ''
      # Nix
      if [ -e /home/ghost/.nix-profile/etc/profile.d/nix.sh ]; then
        . /home/ghost/.nix-profile/etc/profile.d/nix.sh
      fi
      
      # Starship prompt
      eval "$(starship init bash)"
      
      # FZF
      [ -f ~/.fzf.bash ] && source ~/.fzf.bash
      
      # Custom prompt
      PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = "$username$hostname$directory$git_branch$git_state$git_status$nix_shell$cmd_duration$line_break$character";
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  # Cấu hình Hyprland
  xdg.configFile."hypr/hyprland.conf".text = ''
    # Monitor setup
    monitor=,preferred,auto,1
    
    # Execute at launch
    exec-once = waybar
    exec-once = dunst
    exec-once = swaybg -i ~/Pictures/wallpaper.jpg
    exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
    exec-once = nm-applet --indicator
    exec-once = blueman-applet
    
    # Input configuration
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
        animation = workspaces, 1, 6, default
    }
    
    # Layout
    dwindle {
        pseudotile = yes
        preserve_split = yes
    }
    
    master {
        new_is_master = true
    }
    
    gestures {
        workspace_swipe = off
    }
    
    # Window rules
    windowrule = float, ^(kitty)$
    windowrule = center, ^(kitty)$
    windowrule = size 800 500, ^(kitty)$
    
    # Keybindings
    $mainMod = SUPER
    
    # Applications
    bind = $mainMod, RETURN, exec, kitty
    bind = $mainMod, Q, killactive
    bind = $mainMod, F, fullscreen
    bind = $mainMod, E, exec, nemo
    bind = $mainMod, D, exec, rofi -show drun
    bind = $mainMod, P, pseudo
    bind = $mainMod, J, togglesplit
    
    # Screenshot
    bind = , PRINT, exec, grim -g "$(slurp)" - | wl-copy
    bind = SHIFT, PRINT, exec, grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +'%Y-%m-%d-%H%M%S').png
    
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
    bind = $mainMod, 6, workspace, 6
    bind = $mainMod, 7, workspace, 7
    bind = $mainMod, 8, workspace, 8
    bind = $mainMod, 9, workspace, 9
    bind = $mainMod, 0, workspace, 10
    
    # Move window to workspace
    bind = $mainMod SHIFT, 1, movetoworkspace, 1
    bind = $mainMod SHIFT, 2, movetoworkspace, 2
    bind = $mainMod SHIFT, 3, movetoworkspace, 3
    bind = $mainMod SHIFT, 4, movetoworkspace, 4
    bind = $mainMod SHIFT, 5, movetoworkspace, 5
    bind = $mainMod SHIFT, 6, movetoworkspace, 6
    bind = $mainMod SHIFT, 7, movetoworkspace, 7
    bind = $mainMod SHIFT, 8, movetoworkspace, 8
    bind = $mainMod SHIFT, 9, movetoworkspace, 9
    bind = $mainMod SHIFT, 0, movetoworkspace, 10
    
    # Special workspace (scratchpad)
    bind = $mainMod, S, togglespecialworkspace, magic
    bind = $mainMod SHIFT, S, movetoworkspace, special:magic
    
    # Scroll through existing workspaces
    bind = $mainMod, mouse_down, workspace, e+1
    bind = $mainMod, mouse_up, workspace, e-1
    
    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow
  '';

  # Cấu hình Waybar
  xdg.configFile."waybar/config".text = ''
    {
      "layer": "top",
      "position": "top",
      "height": 30,
      "modules-left": ["hyprland/workspaces", "hyprland/window"],
      "modules-center": ["clock"],
      "modules-right": ["pulseaudio", "network", "bluetooth", "battery", "tray"],
      "clock": {
        "format": "{:%H:%M  %d/%m/%Y}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "interval": 1
      },
      "pulseaudio": {
        "format": "{volume}% {icon}",
        "format-bluetooth": "{volume}% {icon}",
        "format-muted": "",
        "format-icons": {
          "headphone": "",
          "hands-free": "",
          "headset": "",
          "phone": "",
          "portable": "",
          "car": "",
          "default": ["", "", ""]
        },
        "scroll-step": 1,
        "on-click": "pavucontrol"
      },
      "network": {
        "interface": "wlp2s0",
        "format": "{ifname}",
        "format-wifi": "  {essid} ({signalStrength}%)",
        "format-ethernet": "  {ifname}",
        "format-disconnected": "⚠  Disconnected",
        "tooltip-format": "{ifname} via {gwaddr}",
        "tooltip-format-wifi": "{essid} ({signalStrength}%) - {ipaddr}/{cidr}",
        "tooltip-format-ethernet": "{ifname} - {ipaddr}/{cidr}",
        "tooltip-format-disconnected": "Disconnected",
        "max-length": 50
      },
      "bluetooth": {
        "format": " {status}",
        "format-disabled": "",
        "format-connected": " {num_connections}",
        "tooltip-format": "{device_alias}",
        "tooltip-format-connected": " {device_enumerate}",
        "tooltip-format-enumerate-connected": "{device_alias}"
      },
      "battery": {
        "states": {
          "warning": 30,
          "critical": 15
        },
        "format": "{capacity}% {icon}",
        "format-charging": "{capacity}% ",
        "format-plugged": "{capacity}% ",
        "format-alt": "{time} {icon}",
        "format-icons": ["", "", "", "", ""]
      },
      "tray": {
        "icon-size": 21,
        "spacing": 10
      }
    }
  '';

  # Cấu hình Rofi
  xdg.configFile."rofi/config.rasi".text = ''
    configuration {
      modi: "drun,run,window";
      show-icons: true;
      icon-theme: "Papirus-Dark";
      terminal: "kitty";
      drun-display-format: "{name}";
      window-format: "{w} · {c} · {t}";
    }
    
    @theme "Arc-Dark"
  '';

  home.packages = with pkgs; [
    # Shell utilities
    starship
    zoxide
    fzf
    eza
    bat
    ripgrep
    fd
    jq
    yq
    
    # Hyprland utilities
    wl-clipboard
    cliphist
    swappy
    wf-recorder
    
    # Themes và icons
    catppuccin-gtk
    papirus-icon-theme
    arc-theme
    
    # Fonts
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "Hack" ]; })
  ];

  # GTK theme
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Compact-Blue-Dark";
      package = pkgs.catppuccin-gtk.override {
        variant = "mocha";
        accents = [ "blue" ];
        size = "compact";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
  };

  # QT theme
  qt = {
    enable = true;
    platformTheme = "gtk";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  # Services
  services = {
    dunst.enable = true;
    gpg-agent.enable = true;
  };

  # State version
  home.stateVersion = "25.05";
}
EOF

# Tạo flake.nix hoàn chỉnh với Home Manager
echo "=== TẠO FLAKE.NIX HOÀN CHỈNH ==="
sudo tee flake.nix << 'EOF'
{
  description = "NixOS-Hyprland for SD Card";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, catppuccin, hyprland, ... } @ inputs: let
    system = "x86_64-linux";
    host = "sdcard";
    username = "ghost";
    
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      config.allowBroken = true;
    };
  in {
    nixosConfigurations."${host}" = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs username host; };
      
      modules = [
        ./hosts/${host}/config.nix
        ./hosts/${host}/home.nix
        
        # Home Manager integration
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./hosts/${host}/home.nix;
          home-manager.extraSpecialArgs = { inherit inputs username host; };
        }
        
        # Hyprland
        hyprland.nixosModules.default
        { programs.hyprland.enable = true; }
        
        # Catppuccin theme
        catppuccin.nixosModules.catppuccin
        {
          catppuccin = {
            enable = true;
            flavor = "mocha";
            accent = "blue";
          };
        }
      ];
    };
    
    # Development shell
    devShells."${system}".default = pkgs.mkShell {
      packages = with pkgs; [
        nixpkgs-fmt
        alejandra
        statix
        deadnix
      ];
    };
    
    # Formatter
    formatter."${system}" = pkgs.alejandra;
  };
}
EOF

echo "=== GENERATE HARDWARE CONFIG ==="
sudo nixos-generate-config --show-hardware-config --dir hosts/sdcard/

echo "=== CÀI ĐẶT HỆ THỐNG (có thể mất 30-60 phút) ==="
echo "Hệ thống sẽ cài đặt tất cả các thành phần..."
echo "1. NixOS base system"
echo "2. Hyprland với đầy đủ config"
echo "3. Waybar, Rofi, và các utilities"
echo "4. Tất cả applications (VSCode, LibreOffice, VLC, browsers, ...)"
echo "5. Home Manager với dotfiles"
echo "6. Themes và fonts"
echo ""
echo "Quá trình có thể mất một thời gian, vui lòng chờ đợi..."

# Build và cài đặt
sudo nixos-install --flake /mnt/etc/nixos#sdcard --show-trace

echo ""
echo "=== CÀI ĐẶT HOÀN TẤT ==="
echo ""
echo "✅ Hệ thống đã được cài đặt thành công!"
echo ""
echo "📋 NHỮNG GÌ ĐÃ ĐƯỢC CÀI ĐẶT:"
echo "----------------------------------------"
echo "🎨 Desktop Environment: Hyprland (Wayland)"
echo "📊 Status Bar: Waybar với đầy đủ module"
echo "🚀 App Launcher: Rofi"
echo "💻 Terminal: Kitty, Foot, Alacritty"
echo "🌐 Browsers: Firefox, Google Chrome, Brave"
echo "📝 Editors: VSCode, Neovim, Helix"
echo "📄 Office: LibreOffice, OnlyOffice"
echo "🎵 Media: VLC, MPV, Audacity"
echo "🎨 Graphics: GIMP, Inkscape, Krita"
echo "📦 File Managers: Nemo, Nautilus"
echo "🔧 System Tools: Btop, GParted, Nala-GUI"
echo "💬 Communication: Telegram, Discord"
echo "🎯 Utilities: 100+ packages và tools"
echo ""
echo "🔧 SAU KHI REBOOT:"
echo "1. Đăng nhập với user 'ghost', password 'password123'"
echo "2. Hyprland sẽ tự động khởi động với đầy đủ config"
echo "3. Mở terminal: Super + Enter"
echo "4. Mở app launcher: Super + D"
echo "5. File manager: Super + E"
echo ""
echo "🛠️ LỆNH QUẢN LÝ HỆ THỐNG:"
echo "• Update: sudo nixos-rebuild switch --upgrade"
echo "• Clean: sudo nix-collect-garbage -d"
echo "• Search package: nix search nixos <tên>"
echo "• List generations: sudo nix-env --list-generations --profile /nix/var/nix/profiles/system"
echo "• Rollback: sudo nixos-rebuild switch --rollback"
echo ""
echo "🚀 CHẠY LỆNH SAU ĐỂ HOÀN TẤT:"
echo "sudo nixos-enter --root /mnt -c 'passwd ghost'"
echo "sudo umount /mnt/boot"
echo "sudo umount /mnt"
echo "sudo reboot"
echo ""
echo "🎉 CHÚC MỪNG! Bạn đã có một hệ thống NixOS với Hyprland đầy đủ!"
