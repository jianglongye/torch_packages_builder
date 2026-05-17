from setuptools import setup
from wheel.bdist_wheel import bdist_wheel


class PlatformWheel(bdist_wheel):
    def finalize_options(self):
        super().finalize_options()
        self.root_is_pure = False
        self.python_tag = "py3"

    def get_tag(self):
        _python, _abi, plat = super().get_tag()
        if plat == "linux_x86_64":
            plat = "manylinux_2_28_x86_64"
        return "py3", "none", plat


setup(cmdclass={"bdist_wheel": PlatformWheel})
