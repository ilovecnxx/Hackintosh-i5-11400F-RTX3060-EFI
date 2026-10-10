# EFI 组件清单

版本从公开快照的 Info.plist 提取；不以下载包名称猜测实际 EFI 驱动版本。

| Kext | 版本 | 配置状态 |
| --- | --- | --- |
| `Lilu.kext` | `1.7.3` | 启用 |
| `AppleALC.kext` | `1.9.9` | 启用 |
| `BlueToolFixup.kext` | `2.7.3` | 启用 |
| `IntelBTPatcher.kext` | `2.5.0` | 启用 |
| `IntelBluetoothFirmware.kext` | `2.5.0` | 启用 |
| `NVMeFix.kext` | `1.1.4` | 启用 |
| `RealtekRTL8111.kext` | `2.4.2` | 启用 |
| `RestrictEvents.kext` | `1.1.7` | 启用 |
| `VirtualSMC.kext` | `1.3.9` | 启用 |
| `SMCProcessor.kext` | `1.3.9` | 启用 |
| `SMCSuperIO.kext` | `1.3.9` | 启用 |
| `USBToolBox.kext` | `1.2.0` | 启用 |
| `UTBDefault.kext` | `1.0` | 启用 |
| `WhateverGreen.kext` | `1.7.2` | 启用 |
| `XHCI-unsupported.kext` | `0.9.2` | 启用 |
| `itlwm.kext` | `2.3.0` | 启用 |

所有启用 ACPI、UEFI driver、kext 的配置引用由 `scripts/verify.py` 检查。OpenCore 准确版本未可靠确认，NullMoth 系统显卡驱动不在本清单内。
