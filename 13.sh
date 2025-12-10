# Login với user 'long'
sudo emerge --sync
sudo emerge -avuDN @world
sudo emerge --depclean
sudo eselect news read all

# Tools for ISO building
sudo emerge app-cdr/cdrtools squashfs-tools sys-fs/squashfuse