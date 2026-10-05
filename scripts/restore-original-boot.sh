#!/bin/sh
set -eu

[ "$(id -u)" -eq 0 ] || { echo "run as root" >&2; exit 1; }
BACKUP=/root/jetson-screen-backup/boot
[ -s "$BACKUP/Image" ] || { echo "backup missing" >&2; exit 1; }

cp -a "$BACKUP/extlinux" /boot/
cp -a "$BACKUP/Image" /boot/Image
cp -a "$BACKUP/initrd" /boot/initrd
cp -a "$BACKUP/kernel_tegra210-p3448-0003-p3542-0000.dtb" /boot/
cp -a "$BACKUP/dtb/kernel_tegra210-p3448-0003-p3542-0000.dtb" /boot/dtb/
sync
echo "Original kernel, initrd, extlinux and board DTB restored."

