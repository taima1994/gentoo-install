{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  time.timeZone = "Asia/Ho_Chi_Minh";

  users.users.youruser = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Hyprland
  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;

  # Audio
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  # Portal (BẮT BUỘC nếu không sẽ lag / app chết)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  security.polkit.enable = true;

  # Fonts (ZaneyOS style)
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    font-awesome
    nerd-fonts.fira-code
  ];

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
  ];

  system.stateVersion = "25.05";
}
