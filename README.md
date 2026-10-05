# Jetson Nano ST7789V + FT6336U BSP

适用于 Jetson Nano 2GB、JetPack 4.6.x / L4T R32.7.1，以及 NVIDIA
`4.9.253-tegra` 内核。

## 硬件

| 功能 | Jetson Nano 40-pin |
|---|---:|
| LCD MOSI | Pin 19 |
| LCD SCLK | Pin 23 |
| LCD CS0 | Pin 24 |
| LCD DC / GPIO Y2 | Pin 15 |
| LCD RESET / GPIO B7 | Pin 18 |
| Touch SDA / I2C-1 | Pin 3 |
| Touch SCL / I2C-1 | Pin 5 |
| Touch INT / GPIO S5 | Pin 29 |
| Touch RESET / GPIO Z0 | Pin 31 |

LCD 与触摸均使用 3.3V 供电。ST7789V 背光当前常亮。

## 当前状态

- 自定义内核：`4.9.253-tegra-st7789`
- ST7789V：`/dev/fb1`，320×240，RGB565，12 MHz SPI
- FT6336U：I2C-1 地址 `0x38`，注册为标准 Linux input 设备
- Xorg：使用 `fbdev` 驱动运行 LXDE、Openbox、LXPanel 和 PCManFM
- 无 HDMI：LightDM 自动登录并在 SPI LCD 上启动桌面
- 有 HDMI：保留 NVIDIA Xorg 桌面
- HDMI 热插拔：状态稳定变化后自动重启 LightDM 并切换显示后端
- 原版 NVIDIA kernel/DTB rescue 启动项保留

## 目录

- `device-tree/`：ST7789V、FT6336U、SPI/I2C/GPIO 配置
- `kernel/`：内核配置、模块参数和补丁
- `xorg/`：fbdev 与触摸坐标配置
- `systemd/`：HDMI/SPI 自动切换服务
- `scripts/`：安装、验证、恢复和 framebuffer 测试工具

## 安装桌面切换

内核、模块和 DTB 正确部署并确认 `/dev/fb1` 后，在 Jetson 上执行：

```bash
sudo ~/jetson-st7789-ft6336/scripts/install-desktop-switch.sh
sudo systemctl restart lightdm
```

HDMI 检测使用 L4T Tegra 接口：

```text
/sys/devices/virtual/switch/hdmi/state
```

切换显示后端会结束当前图形会话，但不会影响 SSH。

## 安全约束

- 不修改 QSPI、`70410000.spi` 或 `spi32766`
- 不修改 SSH、以太网或网络共享配置
- 所有 `/boot` 修改前必须备份
- 始终保留原版 NVIDIA kernel 与 DTB 的 rescue 启动项
