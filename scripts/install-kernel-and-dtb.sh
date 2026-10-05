#!/bin/sh
set -eu

PROJECT=/home/linsiling/jetson-st7789-ft6336
BUILD="$PROJECT/kernel/build-st7789"
KERNEL_RELEASE=4.9.253-tegra-st7789
IMAGE="$BUILD/arch/arm64/boot/Image"
DTB="$PROJECT/device-tree/kernel_tegra210-p3448-0003-p3542-0000-st7789-ft6336.dtb"
EXTLINUX="$PROJECT/scripts/extlinux.conf.st7789"

[ "$(id -u)" -eq 0 ] || { echo "run as root" >&2; exit 1; }
[ -s "$IMAGE" ] || { echo "missing $IMAGE" >&2; exit 1; }
[ -s "$DTB" ] || { echo "missing $DTB" >&2; exit 1; }
[ -s "$EXTLINUX" ] || { echo "missing $EXTLINUX" >&2; exit 1; }
grep -q 'nvidia,p3542-0000+p3448-0003' /proc/device-tree/compatible || {
    echo "wrong Jetson board" >&2
    exit 1
}

# The complete pre-change /boot tree must already exist.
[ -s /root/jetson-screen-backup/boot/Image ] || {
    echo "missing rescue backup" >&2
    exit 1
}

install -m 0644 "$IMAGE" "/boot/Image-$KERNEL_RELEASE"
make -C "$PROJECT/kernel/nvidia-src/Linux_for_Tegra/source/public/kernel/kernel-4.9" \
    O="$BUILD" modules_install
depmod "$KERNEL_RELEASE"

install -m 0644 "$DTB" \
    /boot/dtb/kernel_tegra210-p3448-0003-p3542-0000-st7789-ft6336.dtb

if [ -e "/boot/initrd.img-$KERNEL_RELEASE" ]; then
    update-initramfs -u -k "$KERNEL_RELEASE"
else
    update-initramfs -c -k "$KERNEL_RELEASE"
fi

install -m 0644 "$EXTLINUX" /boot/extlinux/extlinux.conf
sync

echo "Installed $KERNEL_RELEASE with original NVIDIA rescue entry."

