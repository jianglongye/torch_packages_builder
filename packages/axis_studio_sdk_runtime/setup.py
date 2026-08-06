from setuptools import Distribution, setup
from setuptools.command.bdist_wheel import bdist_wheel


class BinaryDistribution(Distribution):
    def has_ext_modules(self) -> bool:
        return True


class PlatformWheel(bdist_wheel):
    def finalize_options(self) -> None:
        super().finalize_options()
        self.root_is_pure = False
        self.python_tag = "py3"

    def get_tag(self) -> tuple[str, str, str]:
        return "py3", "none", "manylinux_2_31_x86_64"


setup(cmdclass={"bdist_wheel": PlatformWheel}, distclass=BinaryDistribution)
