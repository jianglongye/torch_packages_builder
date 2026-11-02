"""Repack the vendor Sharpa SDK tarball (unpacks to SDK/) into one wheel per prebuilt CPython extension.

Wheel layout: sharpa/{__init__.py, sharpa.cpython-3XY-*.so, lib/libsharpa-wave-sdk.so, lib/libSharpaWaveSDKWrapper.so}.
The extension and the wrapper get an $ORIGIN-relative RUNPATH, so no LD_LIBRARY_PATH is needed at import time.

    python build_wheels.py SDK_5_0_2.tar.gz --version 5.0.2+abc1234 --platform manylinux_2_31_x86_64 --out-dir dist
"""

import argparse
import os
import re
import shutil
import subprocess
import tarfile
import tempfile
from pathlib import Path

PACKAGE_DIR = Path(__file__).resolve().parent
EXT_PATTERN = re.compile(r"^sharpa\.cpython-3(\d+)-x86_64-linux-gnu\.so$")
REQUIRED_LIBS = ("libsharpa-wave-sdk.so", "libSharpaWaveSDKWrapper.so")


def patchelf(*args: str) -> None:
    subprocess.run(["uvx", "patchelf", *args], check=True)


def build_one(sdk: Path, ext: Path, minor: str, version: str, platform: str, out_dir: Path) -> None:
    staging = PACKAGE_DIR / "staging" / f"cp3{minor}"
    shutil.rmtree(staging, ignore_errors=True)
    shutil.copytree(PACKAGE_DIR, staging, ignore=shutil.ignore_patterns("staging", "build", "*.egg-info", "dist"))
    package = staging / "sharpa"
    shutil.copytree(
        sdk / "python" / "sharpa",
        package,
        ignore=lambda _, names: [n for n in names if (EXT_PATTERN.match(n) and n != ext.name) or n == "__pycache__"],
    )
    lib_dir = package / "lib"
    lib_dir.mkdir()
    for lib in sorted((sdk / "lib").glob("*.so*")):
        shutil.copy2(lib, lib_dir / lib.name, follow_symlinks=True)
    for name in REQUIRED_LIBS:
        assert (lib_dir / name).is_file(), f"{name} missing from SDK/lib"

    for lib in lib_dir.glob("*.so*"):
        patchelf("--set-rpath", "$ORIGIN", str(lib))
    patchelf("--set-rpath", "$ORIGIN/lib", str(package / ext.name))

    pyproject = staging / "pyproject.toml"
    pyproject.write_text(pyproject.read_text().replace('version = "5.0.2"', f'version = "{version}"', 1))
    subprocess.run(
        ["uv", "build", "--wheel", "--python", f"3.{minor}", "--out-dir", str(out_dir), str(staging)],
        check=True,
        env={**os.environ, "SHARPA_WHEEL_PLATFORM": platform},
    )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tarball", type=Path)
    parser.add_argument("--version", required=True)
    parser.add_argument("--platform", required=True)
    parser.add_argument("--out-dir", type=Path, required=True)
    args = parser.parse_args()

    with tempfile.TemporaryDirectory() as folder, tarfile.open(args.tarball) as tar:
        tar.extractall(folder, filter="data")
        sdk = Path(folder) / "SDK"
        assert (sdk / "python" / "sharpa" / "__init__.py").is_file(), "tarball must unpack to SDK/python/sharpa/"
        exts = [
            (p, m.group(1)) for p in sorted((sdk / "python" / "sharpa").iterdir()) if (m := EXT_PATTERN.match(p.name))
        ]
        assert exts, "no sharpa.cpython-3XY-x86_64-linux-gnu.so found in SDK/python/sharpa/"
        print("Prebuilt extensions:", [p.name for p, _ in exts])
        for ext, minor in exts:
            build_one(sdk, ext, minor, args.version, args.platform, args.out_dir.resolve())
    shutil.rmtree(PACKAGE_DIR / "staging", ignore_errors=True)


if __name__ == "__main__":
    main()
