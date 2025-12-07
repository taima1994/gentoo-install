# 11. Cấu hình hostname + hosts
echo "ghost-pc" > /etc/hostname
cat > /etc/hosts << 'EOF'
127.0.0.1   localhost
::1         localhost
127.0.1.1   ghost-pc.localdomain ghost-pc
EOF
