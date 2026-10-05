# Device Tree notes

The production input is `st7789-ft6336-overlay.dts`. It targets the exact live
Nano 2GB board compatible string and uses only J6 pins supplied in the wiring
table. `jetson-io-spi1-pinmux.*` is retained as an NVIDIA-generated reference
for the SPI1 pinmux values.

The overlay is compiled with symbols (`dtc -@`) and merged into a copy of the
stock DTB. The stock DTB remains untouched and is retained by the rescue boot
entry.

