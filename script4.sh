#!/bin/bash
# Ghost Script4 v1.1: Proxy & Desktop (INSIDE chroot)
# Usage: chroot> ./script4.sh --chaos=true

set -euo pipefail

CHAOS="${1:-true}"

pip install matplotlib rdkit numpy torch --quiet

# Proxy
emerge app-vpn/v2ray dev-lang/go net-misc/nginx
go mod init ghost-proxy
cat > main.go << 'GOMAIN'
package main
import ("net/http"; "log"; "crypto/tls")
var ips = []string{"your-ip1", "your-ip2"}
func handler(w http.ResponseWriter, r *http.Request) { w.Write([]byte("Ghost Proxy Active")) }
func main() {
    mux := http.NewServeMux(); mux.HandleFunc("/", handler)
    srv := &http.Server{ Addr: ":443", TLSConfig: &tls.Config{MinVersion: tls.VersionTLS13}, Handler: mux }
    log.Fatal(srv.ListenAndServeTLS("cert.pem", "key.pem"))
}
GOMAIN
go build -o ghost-proxy main.go
systemctl enable v2ray@config

# Desktop
emerge gui-wm/hyprland media-video/mesa x11-drivers/amdgpu-pro
emerge x11-misc/xdg-desktop-portal-hyprland

# Theme
python3 -c "
import matplotlib.pyplot as plt; import numpy as np; from rdkit import Chem
fig, ax = plt.subplots(); chaos = np.random.rand(10,10); ax.imshow(chaos, cmap='plasma'); plt.savefig('/usr/share/backgrounds/ghost-chaos.png')
mol = Chem.MolFromSmiles('C'); Chem.Draw.MolToImage(mol).save('/usr/share/icons/ghost-encrypt.png')
print('Theme: Generated')
"

# Chaos
if [ "$CHAOS" = "true" ]; then
  entropy=$(cat /dev/urandom | tr -dc '0-9a-f' | fold -w 32 | head -n 1)
  echo $entropy > /etc/v2ray/entropy.txt  # Randomize later
  echo "[GHOST4] Chaos activated"
fi

# Test
./ghost-proxy & sleep 1; kill $! && echo "[GHOST4] Proxy OK! Run Script5"
