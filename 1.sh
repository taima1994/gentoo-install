# Kiểm tra terminal nào có sẵn
which kitty && echo "Kitty OK"
which foot && echo "Foot OK" 
which alacritty && echo "Alacritty OK"

# Nếu không có terminal nào, cài ngay
sudo nixos-rebuild switch

# Hoặc cài tạm qua nix-shell
nix-shell -p kitty --run "kitty"