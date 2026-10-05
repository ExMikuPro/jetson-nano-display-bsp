# Jetson Nano ST7789V + FT6336U

Target: Jetson Nano 2GB, L4T R32.7.1 / JetPack 4.6.x, Linux 4.9.253-tegra.

The work is intentionally staged. No Device Tree GPIO numbers will be chosen
until the physical wiring is recorded and verified.

## Progress

- Stage 0: completed. Full `/boot` backup and checksums are under
  `/root/jetson-screen-backup`.
- Stage 1: SPI1 pinmux and custom DTB prepared; kernel build in progress.
- Stages 2-12: not yet validated.

See `docs/stage-0-audit.md` for the captured findings and safety constraints.
