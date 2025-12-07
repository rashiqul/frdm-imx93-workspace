from conan import ConanFile
from conan.tools.cmake import CMake, cmake_layout, CMakeToolchain
from conan.tools.files import copy
import os

class Imx93Workspace(ConanFile):
    name = "imx93_workspace"
    version = "0.1.0"
    license = "MIT"  # Change to your license
    author = "Your Name <your.email@example.com>"
    url = "https://github.com/rashiqul/frdm-imx93-workspace"
    description = "Multi-core workspace for FRDM-i.MX93 (A55 + M33)"
    topics = ("embedded", "imx93", "cortex-a55", "cortex-m33")
    
    settings = "os", "compiler", "build_type", "arch"
    options = {
        "with_fmt": [True, False],
        "build_a55": [True, False],
        "build_m33": [True, False],
        "shared": [True, False],
        "fPIC": [True, False]
    }
    default_options = {
        "with_fmt": True,
        "build_a55": True,
        "build_m33": False,
        "shared": False,
        "fPIC": True
    }
    
    generators = "CMakeDeps", "CMakeToolchain"
    exports_sources = "CMakeLists.txt", "apps/*", "drivers/*", "libs/*", "toolchains/*"

    def config_options(self):
        if self.settings.os == "Windows":
            del self.options.fPIC

    def configure(self):
        if self.options.shared:
            self.options.rm_safe("fPIC")

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

    def package(self):
        # Copy license
        copy(self, "LICENSE*", src=self.source_folder, dst=os.path.join(self.package_folder, "licenses"))
        
        # Copy headers (if you have shared headers in the future)
        copy(self, "*.h", src=os.path.join(self.source_folder, "libs"), dst=os.path.join(self.package_folder, "include"), keep_path=True)
        copy(self, "*.hpp", src=os.path.join(self.source_folder, "libs"), dst=os.path.join(self.package_folder, "include"), keep_path=True)
        
        # Copy built binaries/libraries
        cm = CMake(self)
        cm.install()

    def package_info(self):
        # Define how consumers should link to this package
        self.cpp_info.libs = []  # Add library names if you create shared libs
        self.cpp_info.includedirs = ["include"]
        
        # Add any required system libs
        if self.settings.os == "Linux":
            self.cpp_info.system_libs = ["pthread", "dl", "m"]
        
        # Set bindir for executables
        self.cpp_info.bindirs = ["bin"]
