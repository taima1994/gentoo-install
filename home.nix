{ config, pkgs, ... }:

{
  home.username = "youruser";
  home.homeDirectory = "/home/youruser";

  programs.git.enable = true;

  home.packages = with pkgs; [
    # Terminal & shell
    kitty
    starship

    # UI / UX
    waybar
    mako
    rofi-wayland
    swaybg
    swaylock
    wl-clipboard
    grim
    slurp

    # App thiết yếu
    thunar
    firefox
    pavucontrol
    networkmanagerapplet
  ];

  # Hyprland config
  home.file.".config/hypr/hyprland.conf".source =
    ./hypr/hyprland.conf;

  programs.waybar.enable = true;
  services.mako.enable = true;

  home.stateVersion = "25.05";
}
