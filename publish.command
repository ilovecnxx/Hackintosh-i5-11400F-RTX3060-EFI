#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
python3 scripts/verify.py
if ! command -v gh >/dev/null; then
  bash scripts/ensure-gh.sh
fi
trap 'unset GH_TOKEN GITHUB_TOKEN' EXIT
if [ -z "${GH_TOKEN:-${GITHUB_TOKEN:-}}" ]; then
  echo '请输入 GitHub 访问令牌（输入不显示，粘贴后按回车）：'
  IFS= read -r -s GH_TOKEN
  echo
  [ -n "$GH_TOKEN" ] || { echo 'STOP: 未输入访问令牌。'; exit 1; }
  export GH_TOKEN
fi
account=$(gh api user --jq .login)
repo=Hackintosh-i5-11400F-RTX3060-EFI
if gh repo view "$account/$repo" >/dev/null 2>&1; then
  echo "STOP: $account/$repo already exists; review it before publishing."
  exit 1
fi
if [ ! -d .git ]; then git init -b main; fi
git config user.name "$account"
git config user.email "$account@users.noreply.github.com"
git add README.md THIRD-PARTY.md PUBLISH.md .gitignore EFI docs licenses scripts SHA256SUMS publish.command
git diff --cached --quiet || git commit -m 'Share sanitized i5-11400F RTX 3060 EFI and installation notes'
gh auth setup-git
gh repo create "$account/$repo" --public --source=. --remote=origin --push \
  --description '黑苹果 i5-11400F + RTX 3060 EFI：macOS 15.8.1、NullMoth 驱动致谢、详细安装和踩坑记录'
gh repo view "$account/$repo" --json url --jq .url
