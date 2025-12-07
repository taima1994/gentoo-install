echo "5. Cài kernel + genkernel (fallback zen nếu fail)"
emerge sys-kernel/gentoo-sources sys-kernel/genkernel sys-kernel/linux-firmware
genkernel all  # Genkernel auto-fix kernel lỗi
