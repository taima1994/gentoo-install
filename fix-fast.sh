# Disable sandbox ngay
echo 'FEATURES="-sandbox -usersandbox"' >> /etc/portage/make.conf
echo 'ACCEPT_LICENSE="*"' >> /etc/portage/make.conf

# Cài kernel binary từ git gentoo
mkdir -p /etc/portage/package.accept_keywords
echo "sys-kernel/gentoo-kernel-bin ~amd64" > /etc/portage/package.accept_keywords/kernel-bin

# Tải trực tiếp nếu emerge lỗi
cd /boot
wget https://gitweb.gentoo.org/repo/gentoo.git/plain/sys-kernel/gentoo-kernel-bin/gentoo-kernel-bin-6.11.5.ebuild
ebuild gentoo-kernel-bin-6.11.5.ebuild manifest
ebuild gentoo-kernel-bin-6.11.5.ebuild merge

# Cài GRUB từ GNU
cd /tmp
wget https://ftp.gnu.org/gnu/grub/grub-2.12.tar.xz
tar xf grub-2.12.tar.xz
cd grub-2.12
./configure
make
make install

grub-install /dev/sda
echo "GRUB cài xong!"
