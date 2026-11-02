import os
import sys

from setuptools import Distribution, setup
from setuptools.command.bdist_wheel import bdist_wheel


class BinaryDistribution(Distribution):
    def has_ext_modules(self) -> bool:
        return True


class PlatformWheel(bdist_wheel):
    """Tag the wheel for the interpreter running the build; the vendor extension is prebuilt for one CPython."""

    def finalize_options(self) -> None:
        super().finalize_options()
        self.root_is_pure = False

    def get_tag(self) -> tuple[str, str, str]:
        python = f"cp{sys.version_info.major}{sys.version_info.minor}"
        return python, python, os.environ["SHARPA_WHEEL_PLATFORM"]


setup(cmdclass={"bdist_wheel": PlatformWheel}, distclass=BinaryDistribution)
