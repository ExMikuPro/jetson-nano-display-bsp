#!/bin/sh
set -u

echo '=== kernel ==='
uname -a

echo '=== framebuffer ==='
cat /proc/fb 2>/dev/null || true
ls -l /dev/fb* 2>/dev/null || true
if [ -c /dev/fb1 ]; then
    fbset -fb /dev/fb1 -i || true
fi

echo '=== expected modules ==='
lsmod | grep -E 'fb_st7789v|fbtft|edt_ft5x06' || true
modinfo fb_st7789v 2>/dev/null | head -20 || true
modinfo edt-ft5x06 2>/dev/null | head -20 || true

echo '=== SPI/I2C devices ==='
find /sys/bus/spi/devices -maxdepth 2 -type l -o -type d 2>/dev/null | sort
find /sys/bus/i2c/devices -maxdepth 1 -name '*-0038' -print 2>/dev/null
i2cdetect -y 1 2>/dev/null || true

echo '=== input ==='
cat /proc/bus/input/devices

echo '=== recent driver log ==='
dmesg | grep -Ei 'st7789|fbtft|fb[0-9]|edt|ft5|ft6|focal|spi|i2c' | tail -200

echo '=== HDMI state ==='
for f in /sys/class/switch/hdmi/state /sys/class/switch/tegradc.0/state; do
    [ -r "$f" ] && echo "$f: $(cat "$f")"
done

