#!/usr/bin/env python3
"""Read-only checks for the public, sanitized EFI snapshot."""
import hashlib
import plistlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OC = ROOT / "EFI" / "OC"
errors = []
private_keys = {
    "mlb", "rom", "systemserialnumber", "systemuuid", "boardserialnumber",
    "systemid", "smuuid", "ssid", "password", "passwordhash", "passwordsalt",
    "fmm-computer-name", "fmm-mobileme-token-fmm", "fmm-mobileme-token-fmm-bridgehasaccount",
}


def check_private(value, path):
    if isinstance(value, dict):
        for key, item in value.items():
            if key.lower() in private_keys:
                allowed = item in ("", b"", "00000000-0000-0000-0000-000000000000")
                if isinstance(item, bytes):
                    allowed = not any(item)
                if not allowed:
                    errors.append(f"Private value not cleared: {path}:{key}")
            check_private(item, path)
    elif isinstance(value, list):
        for item in value:
            check_private(item, path)


def require(base, relative):
    path = base / relative
    if not path.resolve().is_relative_to(base.resolve()):
        errors.append(f"Reference escapes EFI directory: {relative}")
    elif not path.is_file():
        errors.append(f"Missing referenced file: {path.relative_to(ROOT)}")


for path in sorted((ROOT / "EFI").rglob("*")):
    if path.is_symlink():
        errors.append(f"Unexpected symlink: {path.relative_to(ROOT)}")
    if path.name.startswith(".") or "config.plist." in path.name:
        errors.append(f"Unexpected private/backup file: {path.relative_to(ROOT)}")
    if path.suffix == ".plist":
        try:
            check_private(plistlib.loads(path.read_bytes()), path.relative_to(ROOT))
        except Exception as exc:
            errors.append(f"Invalid plist: {path.relative_to(ROOT)}: {exc}")

config = plistlib.loads((OC / "config.plist").read_bytes())
for entry in config["ACPI"]["Add"]:
    if entry["Enabled"]:
        require(OC / "ACPI", entry["Path"])
for entry in config["Kernel"]["Add"]:
    if entry["Enabled"]:
        require(OC / "Kexts", entry["BundlePath"] + "/" + entry["PlistPath"])
        if entry["ExecutablePath"]:
            require(OC / "Kexts", entry["BundlePath"] + "/" + entry["ExecutablePath"])
for category, directory in (("Drivers", "Drivers"),):
    for entry in config["UEFI"][category]:
        if entry["Enabled"]:
            require(OC / directory, entry["Path"])
for entry in config["Misc"]["Tools"]:
    if entry["Enabled"]:
        require(OC / "Tools", entry["Path"])
    if entry["Path"] == "NullMothSafe.efi" and entry["Enabled"]:
        errors.append("Machine-specific recovery tool must be disabled")
require(ROOT / "EFI", "Boot/BOOTx64.efi")
require(OC, "OpenCore.efi")

listed = set()
for line in (ROOT / "SHA256SUMS").read_text().splitlines():
    expected, relative = line.split("  ", 1)
    path = ROOT / relative
    if not path.resolve().is_relative_to((ROOT / "EFI").resolve()):
        errors.append(f"Checksum path escapes EFI: {relative}")
        continue
    listed.add(relative)
    if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != expected:
        errors.append(f"Checksum mismatch: {relative}")
actual = {str(p.relative_to(ROOT)) for p in (ROOT / "EFI").rglob("*") if p.is_file()}
if actual != listed:
    errors.append("Checksum manifest does not cover exactly all EFI files")
if errors:
    raise SystemExit("\n".join(errors))
print(f"PASS: {len(actual)} EFI files; plist, references, privacy fields and SHA-256 verified.")
print("OpenCore ocvalidate and hardware boot testing are separate checks.")
