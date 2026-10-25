# 机械革命 旷世X 的黑苹果 EFI

一句话介绍：一台 2026 年的游戏本，正在冒充 2019 年的 MacBook Pro，而且内屏是靠一个非官方的 NVIDIA 驱动点亮的。

本仓库只服务这一台机器（BIOS `N.1.08MRO07`），不是通用 EFI。拿去装别的机器，大概率会在开机第一秒收获一个禁止符号。

## 这台机器

| 部件 | 硬件 | macOS 下的下场 |
|------|------|----------------|
| CPU | Intel Core i7-14650HX，16 核 24 线程 | 能用。被 SMBIOS 强行登记成 2019 款 MBP 的 i9 |
| 独显 | NVIDIA GeForce RTX 5060 Laptop | 内屏 2560×1600 @180Hz 就是它点的，靠第三方驱动，不是官方支持 |
| 核显 | Intel UHD Graphics | 闲着。内屏物理直连 5060，`SSDT-PNLF` 已禁用 |
| 内存 | 16GB DDR5-5600（单条 Essencore） | 能用，单通道，跑分的时候心里有点堵 |
| 硬盘 | Kingston OM8TAP4512K1-A00 512GB NVMe | 能用 |
| 屏幕 | BOE NS160QDM-NY2，16 英寸 2560×1600 180Hz | 能用，这是这台机器最值钱的部分 |
| 无线 | Intel Wi-Fi 6 AX201 | 能用（AirportItlwm）。隔空投送、随航别想，Intel 网卡的通病 |
| 蓝牙 | Intel 蓝牙 | 能用（IntelBluetoothFirmware + BlueToolFixup） |
| 有线网卡 | Motorcomm YT6801 | 不能用。没驱动，插网线等于插了根装饰品 |
| 声卡 | Conexant CX8070 | 能用，但见下文，这是全场唯一需要手工伺候的部件 |
| SMBIOS | `MacBookPro16,1` | 伪装成 2019 年 16 寸 MBP。那年它还在用 Intel，我们也是 |

## 目录结构

- `Sequoia_15.8.1_EFI_WithDriver/` — Sequoia 15.8.1，装好第三方 NVIDIA 驱动之后用
- `Tahoe_26.7.1/Tahoe_WithDriver/` — Tahoe 26.7.1 主力配置，装好驱动之后用
- `Tahoe_26.7.1/Tahoe_NoNVDriver/` — 安装阶段用的。这时候系统里还没装第三方 NVIDIA 驱动（NullMoth / nvidia-macos-driver），先拿它把 macOS 装进去：
  - `EFI_v1` — 和 `Tahoe_WithDriver` 同源，声卡处理一模一样，区别是无线相关 kext 全关，也没带 `NullMothSafe.efi` 那两个救急工具
  - `EFI_v2` — 完全另一套思路（itlwm + USBToolBox + 自己一整套 SSDT），没有 AppleALC，也没有任何声卡处理

顺序别搞反：先用 `NoNVDriver` 把系统装完、把驱动装好，再换 `WithDriver` 正常用。装都没装就上 `WithDriver`，它也不知道该驱动谁。

## 声卡 CX8070：这台机器唯一需要"特殊处理"的地方

Conexant 的 HDA 芯片，AppleALC 支持得不算痛快，所以这套 EFI 里堆了一套组合拳。Sequoia、`Tahoe_WithDriver`、`EFI_v1` 三套里的声卡相关配置完全一致。

### 1. 驱动和布局

- AppleALC V1.9.8
- boot-args 里塞 `-alcdbg alcid=15`：layout 用 15，`-alcdbg` 打开日志方便看它到底认没认出这颗芯片
- `DeviceProperties` 里**故意没有** HDEF 条目。layout 只从 boot-arg 走，避免两个地方同时注入打架

### 2. 六条 ACPI 二进制改名（config.plist → ACPI → Patch，全部启用）

| 改名 | 干什么用的 |
|------|-----------|
| `HDAS` → `HDEF` | Windows 那边声卡叫 HDAS，macOS 只认 HDEF，改个名 |
| HPET `_STA` → `XSTA` | 把原厂 HPET 的 _STA 藏起来，交给 SSDT 重建 |
| HPET `_CRS` → `XCRS` | 同上，_CRS 也藏起来 |
| IPIC IRQ 2 / RTC IRQ 8 / TIMR IRQ 0 fix | 把 2、8、0 号中断从这几个设备手里拿掉，不拿掉声卡就抢不到中断，然后你就得到一个能调音量但不出声的系统 |

### 3. SSDT

- [SSDT-HPET-CXDSP.aml](Tahoe_26.7.1/Tahoe_WithDriver/EFI/OC/ACPI/SSDT-HPET-CXDSP.aml)（启用）— 配合上面的 XSTA/XCRS 改名，给 HPET 重建 `_CRS`（`IRQNoFlags {0,8}` + `0xFED00000`）和 `_STA`。就是 AppleALC 标准的那套 HPET/IRQ 修复，只是文件名是我自己起的
- [SSDT-HDEF.aml](Tahoe_26.7.1/Tahoe_WithDriver/EFI/OC/ACPI/SSDT-HDEF.aml)（禁用）— 早期用 `_DSM` 注入 layout 15 的尝试
- [SSDT-HDEF-ALC21.aml](Tahoe_26.7.1/Tahoe_WithDriver/EFI/OC/ACPI/SSDT-HDEF-ALC21.aml)（禁用）— 换 layout 21 的尝试，试完发现还是 15 好使，文件留着当纪念

源码在同目录的 `.dsl` 文件里，改完记得重新编译成 `.aml`。

### 4. 怎么验证

命令清单在 [CX8070_TEST_COMMANDS.txt](Tahoe_26.7.1/Tahoe_WithDriver/EFI/OC/CX8070_TEST_COMMANDS.txt)，重点两条：

- `nvram -p | grep alcid` — 确认 `alcid=15` 真的进了 NVRAM
- `ioreg -lw0 -r -c AppleHDAController | grep layout-id` — 确认布局注进去了

预期是 `AppleHDADriver` 注册成功，设置里冒出内建音频。没声音就翻 `-alcdbg` 的日志，先看它有没有认出 CX8070。

### 5. 换 layout 的注意事项

想试别的 layout，**改 boot-arg 里的 `alcid=`**，别去启用那两个 SSDT-HDEF。两条注入路径同时开着，结果不是声音更好，是玄学。

## 显卡：为什么这套叫 WithDriver

苹果官方从没支持过这块卡。内屏能亮、能跑 180Hz，全靠系统里装的第三方驱动（NullMoth / nvidia-macos-driver）——注意驱动是装进 macOS 的，EFI 里没有它，EFI 负责的是下面这串 boot-args 和两个救急工具。也因此 `SSDT-PNLF`（给 Intel 核显调亮度用的）被禁用了，内屏根本不由核显驱动。

`WithDriver` 那两套里，boot picker 还多了两个救生工具（由 `NullMothSafe.efi` 提供）：

- `1401: Remove NVIDIA driver` — 下次开机把驱动摘掉
- `1401: Start once without NVIDIA driver` — 就这次不带驱动启动

更新完系统开机黑屏，别慌，先进 picker 点第二个。能进系统就说明只是驱动没跟上，不是系统挂了。

显卡相关 boot-args：`nvfb=1 nvaccel=1 nvfbheads=4 -nvkmsnosmooth gfxrst=4 nvrmacpibl=1`。看着像乱码，其实是给驱动开关帧缓冲、加速、头数、复位行为的。

## 其余 boot-args 速查

| 参数 | 苦衷 |
|------|------|
| `-v keepsyms=1 debug=0x100` | 出问题要看代码滚屏，不然只能靠猜 |
| `amfi=0x80 amfi_get_out_of_my_way=0x1 -amfipassbeta` | 关掉 AMFI，配合 AMFIPass.kext，不然驱动加载不了 |
| `ipc_control_port_options=0` | 新系统上不给这个，不少第三方软件会直接崩 |
| `alcid=15 -alcdbg` | 声卡（见上） |

另外：SIP 是半关的（`0x0A43`），`SecureBootModel` 是 `Disabled`，`prev-lang:kbd` 设了简体中文，开机不用摸黑选语言。

## 现在能干什么

- 内屏 2560×1600 180Hz 正常显示
- 键盘、触摸板（VoodooI2C + VoodooPS2 两套都备着）、亮度键
- Wi-Fi、蓝牙
- 电池电量、CPU 温度（SMCBatteryManager / SMCProcessor / SMCSuperIO）
- USB
- 声音

## 现在还不能干什么

- 有线网口（YT6801 没驱动，请用 Wi-Fi）
- 隔空投送、随航、通用控制这类 Continuity 功能
- 睡眠唤醒之后什么都不出问题——这条我没法替你保证
