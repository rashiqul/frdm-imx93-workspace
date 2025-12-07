from conan import ConanFile
from conan.tools.cmake import CMake, cmake_layout

class Imx93Workspace(ConanFile):
    name = "imx93_workspace"
    version = "0.1.0"
    settings = "os", "compiler", "build_type", "arch"
    options = {"with_fmt": [True, False]}
    default_options = {"with_fmt": True}
    generators = "CMakeDeps", "CMakeToolchain"

    def requirements(self):
        # spdlog 1.14.1 requires fmt/10.2.1, so we use that version
        if self.options.with_fmt:
            self.requires("fmt/10.2.1")
        self.requires("spdlog/1.14.1")

    def layout(self):
        cmake_layout(self, build_folder="build/conan")

    def build(self):
        cm = CMake(self)
        cm.configure()
        cm.build()
