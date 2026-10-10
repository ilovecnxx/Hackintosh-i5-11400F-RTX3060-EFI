#!/bin/bash
# Install a checksum-verified GitHub CLI in the user's directory, without sudo.
set -euo pipefail
[[ "$(uname -s)" == Darwin ]] || { echo 'This bootstrap supports macOS only.'; exit 1; }
case "$(uname -m)" in
  x86_64) architecture=amd64 ;;
  arm64) architecture=arm64 ;;
  *) echo 'Unsupported CPU architecture'; exit 1 ;;
esac
temporary=$(mktemp -d "${TMPDIR:-/tmp}/efi-gh-XXXXXX")
trap 'rm -rf "$temporary"' EXIT
curl --fail --silent --show-error --location --proto '=https' --tlsv1.2 \
  --connect-timeout 20 --max-time 120 \
  https://api.github.com/repos/cli/cli/releases/latest -o "$temporary/release.json"
python3 - "$temporary" "$architecture" <<'PY'
import json
import re
import sys
from pathlib import Path

directory, architecture = Path(sys.argv[1]), sys.argv[2]
release = json.loads((directory / "release.json").read_text())
version = release["tag_name"].removeprefix("v")
if not re.fullmatch(r"\d+\.\d+\.\d+", version):
    raise SystemExit("Unexpected GitHub CLI version format")
archive = f"gh_{version}_macOS_{architecture}.zip"
checksums = f"gh_{version}_checksums.txt"
assets = {item["name"]: item["browser_download_url"] for item in release["assets"]}
for name, output in ((archive, "archive-url"), (checksums, "checksums-url")):
    url = assets[name]
    if not url.startswith("https://github.com/cli/cli/releases/download/"):
        raise SystemExit("Unexpected download host")
    (directory / output).write_text(url)
(directory / "archive-name").write_text(archive)
PY
archive=$(<"$temporary/archive-name")
curl --fail --silent --show-error --location --proto '=https' --tlsv1.2 \
  --connect-timeout 20 --max-time 300 "$(<"$temporary/archive-url")" -o "$temporary/$archive"
curl --fail --silent --show-error --location --proto '=https' --tlsv1.2 \
  --connect-timeout 20 --max-time 120 "$(<"$temporary/checksums-url")" -o "$temporary/checksums.txt"
python3 - "$temporary" "$archive" <<'PY'
import hashlib
import sys
import zipfile
from pathlib import Path

directory, name = Path(sys.argv[1]), sys.argv[2]
matches = [line.split()[0] for line in (directory / "checksums.txt").read_text().splitlines()
           if len(line.split()) == 2 and line.split()[1].lstrip("*") == name]
if len(matches) != 1 or hashlib.sha256((directory / name).read_bytes()).hexdigest() != matches[0]:
    raise SystemExit("GitHub CLI archive checksum verification failed")
with zipfile.ZipFile(directory / name) as archive:
    executables = [item for item in archive.namelist() if item.endswith("/bin/gh")]
    if len(executables) != 1:
        raise SystemExit("Unexpected archive contents")
    destination = Path.home() / ".local/bin/gh"
    if destination.exists() or destination.is_symlink():
        raise SystemExit("Refuse to overwrite an existing local gh")
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(archive.read(executables[0]))
    destination.chmod(0o755)
    print("GitHub CLI checksum verified and installed in ~/.local/bin/gh")
PY
