#!/bin/bash
# Script4-Simple: Proxy & Hyprland (IN CHROOT) - Light version

echo "=== GHOST4: Proxy stub (V2Ray basic) ==="
emerge app-vpn/v2ray dev-lang/go net-misc/nginx || echo "Internet? Emerge manual"

go mod init ghost-proxy
cat > main.go << 'EOF'
package main
import "fmt"
func main() { fmt.Println("Ghost Proxy Stub Ready") }
EOF
go build -o ghost-proxy main.go
echo "Proxy stub OK (full config sau)"

echo "Desktop light:"
emerge gui-wm/hyprland media-video/mesa || echo "Fallback: emerge x11-base/xorg-server"

echo "Theme basic (manual gen sau):"
mkdir -p /usr/share/backgrounds
echo "Abstract Ghost" > /usr/share/backgrounds/ghost.txt  # Placeholder

echo "=== GHOST4 HOÀN THÀNH! Chạy Script5 ==="