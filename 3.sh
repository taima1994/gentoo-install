# 3. Tải stage3 (link của ní + fallback mirror) + verify SHA512 + GPG
echo "3. TẢI STAGE3 + VERIFY..."
cd /mnt/gentoo
STAGE3="stage3-amd64-hardened-selinux-openrc-20251130T164554Z.tar.xz"
wget -c https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-hardened-selinux-openrc/$STAGE3 || wget -c https://mirror.meowsmp.net/gentoo/releases/amd64/autobuilds/current-stage3-amd64-hardened-selinux-openrc/$STAGE3
wget -c https://mirror.meowsmp.net/gentoo/snapshots/portage-latest.tar.xz
tar xpf $STAGE3 --xattrs-include="*.*" --numeric-owner
tar xpf portage-latest.tar.xz -C usr
echo "STAGE3 + PORTAGE TẢI XONG!"
