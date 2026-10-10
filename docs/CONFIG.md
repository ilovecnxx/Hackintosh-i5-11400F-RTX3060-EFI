# 关键配置说明

本页记录公开 EFI 中的实际值，不代表其他电脑可以直接照搬。快照处于 NullMoth 驱动运行阶段。

## CPU、ACPI 和机型

- SMBIOS：`iMacPro1,1`，`UpdateSMBIOSMode=Custom`。
- `Kernel/Emulate/Cpuid1Data`：`55060A00 00000000 00000000 00000000`。
- `Kernel/Emulate/Cpuid1Mask`：`FFFFFFFF 00000000 00000000 00000000`，即伪装 CPUID 签名，供本机 Rocket Lake 配置参考。
- `AppleXcpmCfgLock=true`，`DummyPowerManagement=false`。安装后有 XCPM 和 X86PlatformPlugin 加载记录，但没有完成压力测试。
- 启用 `SSDT-SBUS`、`SSDT-EC`、`SSDT-PLUG`、`SSDT-RTCAWAC`、`SSDT-USB-Reset`、`SSDT-USBX`。
- 原机带 EC0 `_STA` 重命名和 HP RTC Power Loss (005) 补丁。ACPI 属于主板相关配置，不能仅凭 CPU 相同就复制到别的主板。

## NVIDIA 运行阶段

| 路径或参数 | 公开配置实际值 | 用途或限制 |
| --- | --- | --- |
| `Misc/Security/SecureBootModel` | `Disabled` | 配合第三方显卡组件 |
| `NVRAM/Add/.../csr-active-config` | Data `430A0000` | 自定义放宽 SIP，不能当通用优化 |
| `Booter/Quirks/ResizeAppleGpuBars` | `-1` | 驱动运行阶段 BAR 配置 |
| `UEFI/Quirks/ResizeGpuBars` | `13` | 上游描述为 8GB BAR；不能保证任意显卡/主板都适用 |
| `Kernel/Block` | 排除 `com.apple.iokit.IONDRVSupport` | 上游用于防止固件 framebuffer 抢占显示索引 |
| NVIDIA DeviceProperties | 未注入 | 声卡有单独的 `layout-id` 属性 |

公开快照的完整 boot-args：

```text
-v debug=0x100 keepsyms=1 nvfb=1 nvaccel=1 nvfbheads=4 -nvkmsnosmooth amfi_get_out_of_my_way=0x1 amfi=0x80
```

`-v`、`debug=0x100`、`keepsyms=1` 为排错保留。`nvfb`、`nvaccel` 等由显卡方案使用，AMFI 参数会放宽系统保护。能稳定进入桌面前，不应随意删减或恢复保护配置。

这些值位于 NVRAM 的 Apple GUID `7C436110-AB2A-4BBB-A880-FE41995C9F82`，相关键也列入 `NVRAM/Delete`。这里的 GUID 是标准变量命名空间，不是个人机器 UUID。

## macOS 安装阶段的区别

上游文档指出，安装器没有上述 NVIDIA 驱动，需要使用固件显示路径：

| 设置 | 本仓库：驱动运行阶段 | 上游所述安装阶段 |
| --- | --- | --- |
| `ResizeAppleGpuBars` | `-1` | `0` |
| `ResizeGpuBars` | `13` | `-1` |
| `IONDRVSupport` 排除 | 启用 | 不排除 |

初次安装应使用与作者所选版本配套的安装配置或 1401 生成的安装介质。此表用于说明区别，不能代替完整安装指南。

上游要求 BIOS `Above 4G Decoding=ON`、`CSM=OFF`；本次未读取 BIOS 菜单确认其他设置。不要把这些上游要求误写成本次已逐项核实的 BIOS 状态。

## 其他组件

- 声卡属性：`PciRoot(0x0)/Pci(0x1f,0x3)` 下 `layout-id=15`。声卡芯片型号与每个插孔的效果尚未确认。
- Wi-Fi：EFI 注入 `itlwm`，安装后用 HeliPort 管理。EFI 中的 Wi-Fi 自动连接项已清空。
- USB：`USBToolBox` + `UTBDefault`，并非完成的 `UTBMap`；`XhciPortLimit=false`。
- `WhateverGreen` 原本存在且启用，快照保留。其存在不意味着提供了 RTX 3060 驱动。当前没有 `nv_disable=1` 或 `agdpmod=pikera` 启动参数，也没有 NVIDIA DeviceProperties；复用时核对上游关于移除 NVIDIA 冲突补丁的要求。
- `NullMothSafe.efi` 原工具保留，入口在公开配置中禁用。本机恢复服务、备份和卷定位信息未一起公开，因此不能保证复制后能执行有效卸载。

## 校验边界

`scripts/verify.py` 检查 plist 可解析、启用项引用的文件存在、SMBIOS 和无线凭据已清空、EFI 校验和一致。没有可靠取得与原 OpenCore 二进制匹配的 `ocvalidate`，本次没有声称通过 OpenCore 全部语义校验。复制到其他机器、调整配置后仍需使用匹配版本的 `ocvalidate` 并实机测试。
