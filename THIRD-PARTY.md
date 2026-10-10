# 第三方项目、署名与许可

EFI 中的第三方二进制、资源及其源码保持原项目的许可。本仓库整理者不对这些项目重新授权，也不将显卡驱动工作归为自己的成果。

| 组件 | 作者或项目 | 上游与许可依据 |
| --- | --- | --- |
| OpenCore、OpenRuntime、ResetNvramEntry、HfsPlus | Acidanthera / 相关上游作者 | [OpenCorePkg](https://github.com/acidanthera/OpenCorePkg)、[OcBinaryData](https://github.com/acidanthera/OcBinaryData)，以所用组件源码许可为准 |
| 启动资源 | Acidanthera OcBinaryData | [上游](https://github.com/acidanthera/OcBinaryData) |
| Lilu | vit9696 / Acidanthera | [上游](https://github.com/acidanthera/Lilu)，本地许可文本见 `licenses/Lilu-BSD-3-Clause.txt` |
| AppleALC | Acidanthera 与贡献者 | [上游](https://github.com/acidanthera/AppleALC) |
| WhateverGreen | Acidanthera 与贡献者 | [上游](https://github.com/acidanthera/WhateverGreen) |
| VirtualSMC、SMCProcessor、SMCSuperIO | Acidanthera 与贡献者 | [上游](https://github.com/acidanthera/VirtualSMC) |
| NVMeFix | Acidanthera 与贡献者 | [上游](https://github.com/acidanthera/NVMeFix) |
| RestrictEvents | Acidanthera 与贡献者 | [上游](https://github.com/acidanthera/RestrictEvents) |
| itlwm、HeliPort | OpenIntelWireless | [itlwm](https://github.com/OpenIntelWireless/itlwm)、[HeliPort](https://github.com/OpenIntelWireless/HeliPort)；HeliPort 不在 EFI 包中 |
| IntelBluetoothFirmware、IntelBTPatcher | OpenIntelWireless | [上游](https://github.com/OpenIntelWireless/IntelBluetoothFirmware) |
| BlueToolFixup | Acidanthera / BrcmPatchRAM | [上游](https://github.com/acidanthera/BrcmPatchRAM) |
| RealtekRTL8111 | Mieze 与贡献者 | [上游](https://github.com/Mieze/RTL8111_driver_for_OS_X) |
| USBToolBox、UTBDefault | USBToolBox | [kext](https://github.com/USBToolBox/kext)、[tool](https://github.com/USBToolBox/tool) |
| XHCI-unsupported | RehabMan / USBInjectAll 项目 | [上游](https://github.com/RehabMan/OS-X-USB-Inject-All) |
| NullMothSafe.efi、显卡安装与恢复方案 | NullMoth Systems | [1401](https://github.com/nullmoth/1401)、[显卡驱动](https://github.com/nullmoth/nvidia-macos-driver)，PolyForm Noncommercial 1.0.0 等 |
| EFI 生成相关项目 | lzhoang2801 / OpCore Simplify、Hardware Sniffer | [OpCore Simplify](https://github.com/lzhoang2801/OpCore-Simplify)、[Hardware Sniffer](https://github.com/lzhoang2801/Hardware-Sniffer)；本地 BSD 许可见 licenses |

组件版本详见 [docs/COMPONENTS.md](docs/COMPONENTS.md)。未确认准确源码修订号的项目不臆造版本匹配关系。

## NullMoth 的贡献与使用限制

Required Notice: Copyright (c) 2026 NullMoth Systems (https://nullmothsystems.com)

许可全文见 `licenses/NullMoth-PolyForm-Noncommercial-1.0.0.md`。本仓库仅用于个人非商业参考，不提供售卖或商业支持，不授予 NullMoth 品牌或商标权利。

系统显卡驱动主体没有打包在 EFI 中，应从作者发布页下载并保留其中的许可、校验和和第三方 NOTICE。驱动中 translator 沿用 metal2vulkan 的 LGPL-3.0-or-later，Mesa NVK 相关部分遵循 MIT，NVIDIA 内核模块和固件分别遵循其自身条款，不能用一个 EFI 仓库许可覆盖全部组件。

本地取得的 NullMoth 第三方贡献说明见 `licenses/NullMoth-NOTICE.txt`。本次无法联网逐项抓取其他上游许可与配套源码，许可链接和版本记录不等于已完成全部组件的再分发许可核验；正式对外再分发时应补齐各组件要求的文本和对应源码材料。
