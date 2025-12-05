# Dòng 73-78
emerge sys-kernel/gentoo-sources sys-kernel/genkernel
eselect kernel set 1
genkernel --kernel-config=/usr/src/linux/.config all
