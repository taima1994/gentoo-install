# 9. Tạo user ghost + sudo
echo "9. Tạo user ghost..."
useradd -m -G wheel,audio,video,portage ghost
echo "ghost:ghost" | chpasswd
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel
