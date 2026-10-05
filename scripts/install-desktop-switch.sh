#!/bin/sh
set -eu

PROJECT=/home/linsiling/jetson-st7789-ft6336
[ "$(id -u)" -eq 0 ] || { echo "run as root" >&2; exit 1; }
[ -c /dev/fb1 ] || { echo "/dev/fb1 is not ready" >&2; exit 1; }

install -m 0755 "$PROJECT/scripts/jetson-display-xserver" \
    /usr/local/sbin/jetson-display-xserver
install -m 0755 "$PROJECT/scripts/jetson-hdmi-connected" \
    /usr/local/sbin/jetson-hdmi-connected
install -m 0755 "$PROJECT/scripts/jetson-display-monitor" \
    /usr/local/sbin/jetson-display-monitor
install -m 0644 "$PROJECT/xorg/xorg-st7789.conf" \
    /etc/X11/xorg-st7789.conf
install -d -m 0755 /etc/X11/xorg-st7789.conf.d
install -m 0644 "$PROJECT/xorg/90-ft6336-touch.conf" \
    /etc/X11/xorg-st7789.conf.d/90-ft6336-touch.conf
install -d -m 0755 /etc/lightdm/lightdm.conf.d
install -m 0644 "$PROJECT/systemd/90-jetson-screen-lightdm.conf" \
    /etc/lightdm/lightdm.conf.d/90-jetson-screen.conf
install -m 0644 "$PROJECT/systemd/jetson-display-monitor.service" \
    /etc/systemd/system/jetson-display-monitor.service

systemctl daemon-reload
systemctl enable jetson-display-monitor.service

echo "LightDM will use NVIDIA Xorg when HDMI is connected and fbdev otherwise."
