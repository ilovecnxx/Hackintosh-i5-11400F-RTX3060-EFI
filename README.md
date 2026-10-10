# 黑苹果 i5-11400F + RTX 3060 EFI

Intel Core i5-11400F + NVIDIA GeForce RTX 3060 12GB 的黑苹果 EFI 与安装、排错记录，供同配置网友参考。

记录日期：2026-10-10。系统为 **macOS Sequoia 15.8.1（24H32）**，SMBIOS 为 `iMacPro1,1`。

> 这是个人机器的脱敏参考配置，仍处于适配和验证阶段。当前日常显示基线为 DP、2560×1440、约 60Hz。144/165Hz 测试出现过闪屏、黑屏、花屏和桌面冻结，不能视为高刷已适配。EFI 已清空机器身份信息，使用前必须填写自己的 SMBIOS，并核对主板、ACPI 和 USB 配置。

## 特别感谢显卡驱动作者

**首先特别感谢 [NullMoth Systems / @nullmoth](https://github.com/nullmoth)**。

这台机器能够在 macOS 15 上识别 RTX 3060，并报告 Metal 支持，依赖作者的 **[NullMoth NVIDIA Driver for macOS](https://github.com/nullmoth/nvidia-macos-driver)**。作者的工作覆盖 NVIDIA 内核驱动适配、显示 framebuffer、加速器、Metal 插件、着色器转换和安装恢复工具。对使用较新 NVIDIA 显卡的黑苹果用户来说，这些工作提供了实际尝试的机会。

本仓库只是个人 EFI 和实机使用记录，**显卡驱动不是本仓库作者开发的**。遇到的兼容性问题会如实记录；问题存在不应掩盖作者投入的工作，也不应把“设备被识别”宣传成“所有应用和高刷新率均已验证”。

- 显卡驱动源码与发布页：[nvidia-macos-driver](https://github.com/nullmoth/nvidia-macos-driver)、[Releases](https://github.com/nullmoth/nvidia-macos-driver/releases)
- 作者的安装工具：[1401](https://github.com/nullmoth/1401)
- 帮助与已知问题：[nullmothsystems.com/help](https://nullmothsystems.com/help)
- 支持作者：[buymeacoffee.com/nullmoth](https://buymeacoffee.com/nullmoth)

本次排错基于 **1.6.0** 的安装和测试记录。电脑上还有其他版本的下载包，下载完成不等于已安装或验证，新版本是否解决本机问题应以重新测试结果为准。

## 硬件与系统

| 项目 | 本机信息 | 备注 |
| --- | --- | --- |
| CPU | Intel Core i5-11400F，6 核 12 线程 | F 型号没有核显，不能靠核显救场 |
| 显卡 | NVIDIA GeForce RTX 3060，12GB | PCI ID `10de:2504`，PCIe x16 |
| 主板 | 具体商品型号待补充 | ACPI 中存在 HP RTC 相关补丁，不能据此猜测主板型号 |
| 内存 | 32GB DDR4 | 安装后报告 3200MHz，两条状态 OK |
| 系统 SSD | WDC SN730 512GB | NVMe，TRIM 开启，检查记录为 SMART Verified |
| 数据盘 | 希捷 2TB SATA | 本机用于 Time Machine，不属于 EFI 包 |
| 显示器 | Mi Monitor，DisplayPort | 基线 2560×1440，约 59.95Hz |
| Wi-Fi | Intel 无线网卡，具体型号待补充 | `itlwm` + HeliPort |
| 蓝牙 | Intel 蓝牙，具体型号待补充 | 控制器枚举成功，配对与唤醒未完整测试 |
| 有线网卡 | 配置包含 RealtekRTL8111 | 未将驱动文件存在当作联网实测通过 |
| 声音 | AppleALC，`layout-id=15` | 板载音频和 USB 耳机均有枚举记录 |
| macOS | Sequoia 15.8.1 / 24H32 | Darwin 24.6.0，x86_64 |
| 机型标识 | iMacPro1,1 | 序列号、MLB、UUID、ROM 已脱敏 |
| OpenCore | 原机 EFI 中的二进制 | 准确版本未可靠确认，升级前请自行核对 |

## 已验证与未完成

| 功能 | 实机记录 | 验证边界 |
| --- | --- | --- |
| 启动并进入桌面 | 已确认 | 不代表每次冷启动和长时间运行都已通过 |
| CPU 电源管理 | XCPM=1，X86PlatformPlugin 已加载 | 满载频率、温度、功耗未做压力测试 |
| RTX 3060 识别 | 系统显示 RTX 3060 12GB、Metal Supported | 未验证完整 Metal 功能、游戏、专业软件和视频编解码 |
| 2K 约 60Hz 桌面 | 故障后恢复到该基线 | 桌面流畅度缺少帧时间量化测试 |
| 144/165Hz | 测试失败 | 曾需要用户强制重启，不建议复现 |
| Wi-Fi | 安装后检查为 en0 active，有默认路由 | 使用 HeliPort 管理，不是原生 AirPort 工作流 |
| 声音 | 输入输出设备枚举 | 每个插孔和声音效果未逐一实测 |
| 蓝牙 | 控制器开启，相关驱动加载记录 | 配对、睡眠后重连、接力和 AirDrop 未确认 |
| USB | 当前使用 USBToolBox + UTBDefault | 尚无完成的主板专属 USB 端口映射 |
| 睡眠、唤醒、关机 | 未完成验证 | 曾见 shutdown stall 记录，原因未定位 |
| 恢复方案 | 已准备本机备份和脚本 | 完整恢复环境回滚未实机验证，机器专用脚本不在公开包中 |

## 仓库内容

```text
EFI/
  Boot/BOOTx64.efi
  OC/
    ACPI/                 本机 SSDT 与补丁配套
    Drivers/              HfsPlus、OpenRuntime、ResetNvramEntry
    Kexts/                基础、网络、声音、蓝牙、USB 驱动
    Resources/            原 EFI 启动资源
    Tools/                原机的 NullMothSafe 工具，公开配置禁用其入口
    OpenCore.efi
    config.plist          脱敏后的驱动运行阶段配置
docs/
  CONFIG.md               关键配置与安装/运行阶段区别
  PITFALLS.md             踩坑、现象、证据与恢复经验
  COMPONENTS.md           EFI 内组件版本和引用检查
  PROVENANCE.md           来源与脱敏变更
licenses/                 本地可取得的第三方许可文本
scripts/verify.py          只读检查配置引用、脱敏和校验和
SHA256SUMS                EFI 文件校验和
```

**RTX 3060 的完整驱动不在 EFI 内。** NullMoth 的四个 kext 安装于 `/Library/Extensions`，Metal 插件、Vulkan 后端和固件还位于系统数据卷的其他目录。只复制本仓库 EFI，不能获得与本机相同的显卡驱动环境。

## 使用顺序

1. **先准备救援 U 盘和备份。** 保留目前可启动的 EFI 与安装/恢复环境，备份当前系统、显卡驱动、插件、固件和 Auxiliary Kernel Collection。i5-11400F 没有核显，显卡驱动出问题后缺少备用显示路径。
2. **核对你的硬件。** 相同 CPU 和显卡不代表主板、USB、声卡、无线网卡和 ACPI 相同。主板型号尚未补充，不能把本 EFI 当作跨主板通用包。
3. **填写自己的 SMBIOS。** 用 [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) 等工具生成 `iMacPro1,1` 的独立 `SystemSerialNumber`、`MLB`、`SystemUUID`，设置自己的 6 字节 `ROM`。公开配置中的空值和零值不能直接用于登录 Apple 服务。
4. **区分安装阶段与驱动运行阶段。** 本仓库保存的是安装显卡驱动后的配置，包含 `IONDRVSupport` 排除和 BAR 调整。初次安装 macOS 时不能直接照搬这组设置；参见 [CONFIG.md](docs/CONFIG.md)。
5. **从作者发布页获取显卡驱动。** 按所选版本原始说明验证包内 `SHA256SUMS`，使用原作者安装程序或 1401。不要把 NullMoth 的四个系统 kext 再注入 `EFI/OC/Kexts`。按照作者要求授权扩展并重启，注销不能代替重启加载内核驱动。
6. **先使用 2560×1440、约 60Hz。** 不要因系统菜单出现 144/165Hz 就认定可以安全启用；本机有真实失败记录。
7. **自行完成 USB 定制。** 使用 [USBToolBox](https://github.com/USBToolBox/tool) 逐口测试 USB 2.0、USB 3.x、Type-C 两个方向和内部蓝牙，生成适合自己主板的映射，按工具说明替换默认映射。
8. **先从测试 U 盘启动。** 填完身份信息后，运行下面的本地检查，并使用与你的 OpenCore 二进制版本匹配的 `ocvalidate` 校验；稳定后再迁移到内置 EFI，保留其他系统的启动文件。

```bash
python3 scripts/verify.py
shasum -a 256 -c SHA256SUMS
```

上述命令验证的是公开快照。填入个人身份信息或修改映射后，脱敏检查和原始文件校验和会有意不通过；这时应校验自己修改后的配置并建立个人备份，**不要把个人版本推送回公开仓库**。

## 启动后检查

以下命令只用于核对状态，输出可能包含个人信息，分享前应脱敏：

```bash
sw_vers
system_profiler SPDisplaysDataType
kmutil showloaded --list-only | grep -i nullmoth
```

核对 `NVRM`、`NVRMFB`、`NVAccel`、`NVRMAGDC` 四个组件以及实际显示器模式。系统写着 Metal Supported，只说明支持标识和接口被系统报告，不能代替应用、持续渲染和视频编解码测试。

## 踩坑重点

- **高刷菜单和调用成功不等于画面可用。** 165Hz 出现闪屏、黑屏；144Hz 排错实验出现鼠标拖影、窗口残影和桌面卡死。具体记录见 [PITFALLS.md](docs/PITFALLS.md)。
- **注销和重启 WindowServer 不一定恢复显示。** 一次实验的看门狗已恢复参数并重启 WindowServer，用户仍需强制重启。
- **EFI 备份不能代替系统驱动备份。** 此方案的关键文件在系统数据卷，AuxKC 也需要配套保留。
- **“Remove NVIDIA driver” 菜单不能当作已验证的救援方案。** 原机曾有该入口失效的记录，而且依赖本机恢复服务；公开配置禁用此工具入口。
- **默认 USB 映射不代表 USB 3.x 正常。** 安装后看到 15 个 USB 2.0 逻辑端口、0 个 USB 3.0 逻辑端口，需要逐口定制。
- **不要把未验证的排错尝试当修复方法。** 禁用 direct flip 的实验失败，未发布可执行的高刷测试脚本；其他网友的色彩配置 workaround 在本机未验证。

## 致谢与使用范围

除 NullMoth Systems 外，感谢 [Acidanthera](https://github.com/acidanthera) 的 OpenCore、Lilu、VirtualSMC、AppleALC、WhateverGreen、NVMeFix、RestrictEvents，感谢 [OpenIntelWireless](https://github.com/OpenIntelWireless)、[USBToolBox](https://github.com/USBToolBox)、RealtekRTL8111 作者 [Mieze](https://github.com/Mieze)、[Dortania](https://dortania.github.io/OpenCore-Install-Guide/) 文档，以及 [OpCore Simplify](https://github.com/lzhoang2801/OpCore-Simplify) / Hardware Sniffer 项目。

显卡实现也建立在 NVIDIA open GPU kernel modules、Mesa NVK 和 Anees Iqbal / steelbrain 的 metal2vulkan 等项目上，完整贡献关系以 [上游 NOTICE](https://github.com/nullmoth/nvidia-macos-driver/blob/main/NOTICE) 为准。

本仓库用于个人学习和交流，不提供商业安装、售卖或付费支持。NullMoth 组件受 **PolyForm Noncommercial 1.0.0** 等上游条款约束；其他组件分别遵循各自许可，详见 [THIRD-PARTY.md](THIRD-PARTY.md)。作者署名和许可不能因 EFI 打包而被覆盖。本仓库不包含 macOS 安装镜像。
