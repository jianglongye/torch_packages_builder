from setuptools import setup
from wheel.bdist_wheel import bdist_wheel


class PlatformWheel(bdist_wheel):
    def finalize_options(self):
        super().finalize_options()
        self.root_is_pure = False
        self.python_tag = "py3"


setup(cmdclass={"bdist_wheel": PlatformWheel})
