cat > ~/setup-hyprland.sh << 'EOF'
#!/bin/bash

# Clone dotfiles
mkdir -p ~/nixos-dotfiles/config
cd ~/nixos-dotfiles/config
git clone https://github.com/tonybanters/hypr
git clone https://github.com/tonybanters/waybar
git clone https://github.com/tonybanters/foot

# Link configs
cd ~/.config
ln -sf ~/nixos-dotfiles/config/hypr hypr
ln -sf ~/nixos-dotfiles/config/waybar waybar
ln -sf ~/nixos-dotfiles/config/foot foot

# Set monitor resolution
echo "monitor=,1920x1080,auto,1" >> ~/.config/hypr/hyprland.conf

# Create minimal flake
cd ~/nixos-dotfiles
cat > flake.nix << 'FLAKE'
{
  description = "Hyprland config";
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.hyprland-btw = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
}
FLAKE

# Create basic config
cat > configuration.nix << 'CONFIG'
{ config, pkgs, ... }: {
  programs.hyprland.enable = true;
  services.xserver.displayManager.sddm.enable = true;
}
CONFIG

echo "Done! Run: sudo nixos-rebuild switch --flake ~/nixos-dotfiles#hyprland-btw"
EOF

# Chạy script
chmod +x ~/setup-hyprland.sh
./setup-hyprland.sh