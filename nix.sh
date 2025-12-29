sudo nano ~/.config/nixpkgs/home.nix

{ config, pkgs, ... }:

{
  home.username = "ghost";
  home.homeDirectory = "/home/ghost";
  home.stateVersion = "25.05";

  # Các ứng dụng cơ bản
  home.packages = with pkgs; [
    # Terminal
    kitty
    alacritty
    foot
    
    # Utilities
    git
    htop
    neofetch
    bat
    eza
    fzf
    ripgrep
    
    # File manager
    nautilus
    ranger
    
    # Browser
    firefox
    google-chrome
    
    # Media
    vlc
    mpv
    
    # Documents
    libreoffice
    zathura
    
    # Graphics
    gimp
    inkscape
    
    # Communication
    telegram-desktop
    discord
  ];

  # Cấu hình Git
  programs.git = {
    enable = true;
    userName = "Ghost";
    userEmail = "ghost@localhost";
  };

  # Cấu hình Bash/Zsh
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      update = "sudo nixos-rebuild switch";
      clean = "sudo nix-collect-garbage -d";
    };
  };

  # Cấu hình terminal (Kitty)
  programs.kitty = {
    enable = true;
    theme = "Catppuccin-Mocha";
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = "12";
      background_opacity = "0.9";
    };
  };
}

# Cài đặt Home Manager nếu chưa có
nix-shell -p home-manager --run "home-manager switch"