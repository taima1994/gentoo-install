# 1. Thêm mount /build vào fstab
echo "UUID=$(sudo blkid -s UUID -o value /dev/sdb4) /build ext4 defaults,noatime 0 2" | sudo tee -a /etc/fstab

# 2. Mount
sudo mkdir -p /build
sudo mount -a

# 3. Tạo thư mục build
sudo mkdir -p /build/{nix-build,iso-cache}
sudo chmod 1777 /build/nix-build

# 4. Cấu hình Nix dùng /build
echo 'nix.settings.build-dir = "/build/nix-build";' | sudo tee -a /etc/nixos/configuration.nix

# 5. Cài Plasma
echo '
services.desktopManager.plasma6.enable = true;
services.displayManager.sddm.enable = true;
services.displayManager.autoLogin.enable = true;
services.displayManager.autoLogin.user = "ghost";
' | sudo tee -a /etc/nixos/configuration.nix

# 6. Rebuild
sudo nixos-rebuild switch