"""Locate the bundled Manus SDK native library."""

import sys
from importlib.resources import files
from pathlib import Path


def library_path() -> Path:
    """Return the platform native Manus SDK library path."""
    lib_dir = files("manus_sdk_runtime") / "lib"
    if sys.platform == "win32":
        return Path(str(lib_dir / "windows" / "ManusSDK.dll"))
    return Path(str(lib_dir / "linux" / "libManusSDK_Integrated.so"))
