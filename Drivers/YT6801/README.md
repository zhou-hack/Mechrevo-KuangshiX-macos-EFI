# Motorcomm YT6801 macOS 驱动

本目录提供适用于 Motorcomm YT6801（PCI `1f0a:6801`）的 macOS DriverKit 驱动安装包：

- `YT6801-Installer-1.0.13-fixed.dmg`
- SHA-256：`72794413628e6fdfa9642b0b4b8894e2e05e3949ac150e1bffff7f2ef5ab57c3`
- 适用环境：macOS 15.2 或更高版本，Intel x86_64

这是 **DEXT 系统扩展，不是 KEXT**。不要把它复制到 `EFI/OC/Kexts`，也不要用 `kextload` 或 `kmutil` 加载。进入 macOS 后打开 DMG，运行其中的 **YT6801 Installer 1.0.13**，按界面完成安装和系统扩展批准即可；通常不需要重启。

## 原作者与版权

本驱动不是本 EFI 仓库作者原创。请保留以下署名：

- **macOS DriverKit 移植及安装器原作者：MiniYv（小禹）**，Copyright (c) 2026 MiniYv
- **底层 Linux `fuxi-gmac` 驱动原作者：Motor-comm Corporation**，Copyright (c) 2021 Motor-comm Corporation

- 上游项目：<https://github.com/MiniYv/yt6801-for-macOS>
- 对应版本：<https://github.com/MiniYv/yt6801-for-macOS/releases/tag/v1.0.13>
- 对应源代码：<https://github.com/MiniYv/yt6801-for-macOS/tree/v1.0.13>

本目录的 `NOTICE` 是上游原始版权说明，`LICENSE` 是上游完整许可证文本，均未改动。

## 许可

本目录中的驱动安装包及其重打包内容依照上游要求，采用 **GNU General Public License v2.0 or later（GPL-2.0-or-later）** 分发。程序按“现状”提供，不附带任何担保；完整条款见 [LICENSE](LICENSE)，原始归属见 [NOTICE](NOTICE)。

该许可说明仅针对本目录的 YT6801 驱动及重打包内容，不改变本仓库其他 EFI、ACPI、配置文件或第三方组件各自的许可。

## `fixed` 包的改动说明

官方 v1.0.13 驱动源码已修复内置网卡授权，但其安装器构建脚本仍引用旧的 `installer/source/dext.entitlements`，导致官方 DMG 内的实际签名未包含该修复。

本包使用官方 v1.0.13 的 DEXT 二进制和官方安装器构建脚本重新打包，唯一源码调整是将 `installer/source/dext.entitlements` 与同版本的 `source/yt6801/yt6801.entitlements` 同步：

- 加入 `com.apple.developer.driverkit.builtin`；
- PCI 匹配使用 `IOPCIPrimaryMatch 0x68011f0a`；
- 未修改或重新编译 DEXT 驱动代码，修复前后的驱动反汇编内容一致；
- 安装器和 DEXT 仍为 ad-hoc 签名，不是 Apple Developer ID 签名或公证版本。

可用以下方式从对应上游源码复现该调整：先复制 `source/yt6801/yt6801.entitlements` 覆盖 `installer/source/dext.entitlements`，再按上游 `installer/scripts/build.sh` 的说明构建安装器。
