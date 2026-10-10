# 发布到 GitHub

仓库内容已在本机准备，**准备完成不等于已上传 GitHub**。本次工具环境无法解析 `api.github.com`，且未发现 GitHub CLI 登录，因此没有生成远程仓库链接。

在 macOS 终端运行：

```bash
bash ~/Documents/Hackintosh-i5-11400F-RTX3060-EFI/publish.command
```

脚本会先检查公开 EFI；如缺少 GitHub CLI，则从官方发布页下载 macOS 版本，校验官方 SHA-256 后安装到 `~/.local/bin/gh`，无需 sudo。

随后在终端提示处粘贴 GitHub 访问令牌并按回车。输入时不会显示字符，**无需 8 位网页设备验证码**。脚本只在当前进程环境中使用令牌，不将其写入仓库、Git 远程地址或 GitHub CLI 登录文件。已有 `GH_TOKEN` 或 `GITHUB_TOKEN` 环境变量时直接使用。

脚本使用令牌对应的账号创建公开仓库 `Hackintosh-i5-11400F-RTX3060-EFI` 并推送本地内容。令牌需要具备创建仓库和推送代码的权限；经典个人访问令牌可使用 `public_repo` 权限。

仓库 README 标题为“黑苹果 i5-11400F + RTX 3060 EFI”。脚本会输出最终仓库网址。若同名仓库已存在，会停止，避免覆盖已有内容。

不要将 GitHub 访问令牌、个人 SMBIOS 或实际 Wi-Fi 密码写入仓库。若提示无法解析或连接 GitHub，先恢复本机对 GitHub 的连接再运行。
