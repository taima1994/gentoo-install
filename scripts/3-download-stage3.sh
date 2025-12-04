#!/bin/bash
set -e
echo "3. TẢI STAGE3 VÀ PORTAGE TREE"
cd /mnt/gentoo

# Link stage3 hardened với SELinux
STAGE3_URL="https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-hardened-selinux-openrc"
STAGE3_FILE="stage3-amd64-hardened-selinux-openrc-20251130T164554Z.tar.xz"

echo "Downloading Stage3..."
wget -c "$STAGE3_URL/$STAGE3_FILE"
echo "Downloading Portage snapshot..."
wget -c https://distfiles.gentoo.org/snapshots/current/portage-latest.tar.xz

# Verify downloads
if [ ! -f "$STAGE3_FILE" ]; then
  echo "ERROR: Stage3 download failed!"
  exit 1
fi

if [ ! -f "portage-latest.tar.xz" ]; then
  echo "ERROR: Portage snapshot download failed!"
  exit 1
fi

# Extract với đầy đủ attributes
echo "Extracting Stage3..."
tar xpf "$STAGE3_FILE" --xattrs-include='*.*' --numeric-owner

echo "Extracting Portage tree..."
tar xpf portage-latest.tar.xz -C usr

echo "STAGE3 + PORTAGE TẢI XONG!"
