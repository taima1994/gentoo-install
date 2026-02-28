# 1. Chấp nhận từ khóa không ổn định cho các gói cần thiết
mkdir -p /etc/portage/package.accept_keywords
cat > /etc/portage/package.accept_keywords/hyprland << EOF
gui-wm/hyprland ~amd64
gui-libs/xdg-desktop-portal-hyprland ~amd64
dev-qt/qtbase ~amd64
dev-qt/qtwayland ~amd64
dev-qt/qtdeclarative ~amd64
dev-qt/qtshadertools ~amd64
EOF

# 2. Bỏ mask (unmask) một số gói Qt nếu cần (dựa theo hướng dẫn mới nhất [citation:5])
mkdir -p /etc/portage/profile
echo -e "dev-qt/qtbase\ndev-qt/qtwayland\ndev-qt/qtdeclarative\ndev-qt/qtshadertools" >> /etc/portage/profile/package.unmask

# 3. Thiết lập USE flags bắt buộc
mkdir -p /etc/portage/package.use
cat > /etc/portage/package.use/hyprland << EOF
dev-qt/qtbase opengl egl eglfs gles2-only
dev-qt/qtdeclarative opengl
sys-apps/xdg-desktop-portal screencast
EOF