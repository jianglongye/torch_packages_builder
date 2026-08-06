"""Locate the bundled Axis Studio SDK native library."""

from importlib.resources import files
from pathlib import Path


def library_path() -> Path:
    """Return the bundled Axis Studio SDK library path.

    >>> library_path().name
    'librobotapi_x86-64.so'
    """
    return Path(str(files("axis_studio_sdk_runtime") / "lib" / "linux" / "librobotapi_x86-64.so"))
