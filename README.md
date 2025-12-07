# FRDM‑i.MX93 Apps & Drivers

Multi-core (A55 Cortex-A55 + M33 Cortex-M33) development workspace for FRDM‑i.MX93 board.

## Technology Stack

- **CMake 3.20+**: Multi-target build system (Unix Makefiles generator)
- **Conan 2.x**: C++ dependency management
- **Poetry**: Python environment and dependency management
- **Make**: Convenience wrappers for common workflows
- **Docker**: Optional containerized build environment

> **Note**: A55 runs Linux (SSH deployable), M33 is bare-metal (flash via uuu/pyOCD/OpenOCD).

## Quick Start

### Prerequisites

```bash
# Install Poetry (choose one):
curl -sSL https://install.python-poetry.org | python3 -
# OR
pipx install poetry
```

### Three Build Options

#### 1. Native Build (Simplest - No Cross-Compilers)

```bash
# Configure and build locally
make configure TARGET=native
make build TARGET=native

# Test the binary
./build/native/apps/a55/hello_app/hello_a55
# Output: [A55] Hello from FRDM‑i.MX93! argc=1
```

Perfect for local development and testing application logic.

#### 2. Cross-Compilation (Production Builds)

```bash
# First, install cross-compilers (see docs/CROSS_COMPILER_SETUP.md)
# Then configure and build for target architecture
make configure TARGET=a55    # For A55 (aarch64)
make build TARGET=a55

# Deploy to board
make run-a55 HOST=imx93.local

# OR for M33
make configure TARGET=m33    # For M33 (arm-none-eabi)
make build TARGET=m33
make flash-m33
```

#### 3. Docker (Pre-configured Environment)

```bash
# Start container with all toolchains installed
make run-docker

# Enter container shell
make docker-shell

# Inside container, build as usual
make configure TARGET=a55
make build TARGET=a55
```

See `docs/DOCKER_SETUP.md` for details.

## Available Make Commands

```bash
make configure TARGET=native|a55|m33  # Setup environment and configure CMake
make build TARGET=native|a55|m33      # Compile and link
make run-a55 HOST=<ip/host>           # Deploy and run on A55 Linux
make flash-m33                        # Flash M33 firmware
make run-docker                       # Start Docker build container
make docker-shell                     # Open shell in container
make clean                            # Remove all build artifacts
```

## Project Structure

```
imx93-apps-drivers/
├── CMakeLists.txt                    # Root build configuration
├── Makefile                          # Convenience wrappers
├── conanfile.py                      # C++ dependencies
├── Dockerfile                        # Docker build environment
├── docker-compose.yml                # Container orchestration
├── apps/
│   ├── a55/hello_app/                # A55 application example
│   └── m33/blinky/                   # M33 application example
├── drivers/                          # Hardware drivers (organize by core)
│   ├── a55/
│   └── m33/
├── libs/                             # Shared libraries
├── python/
│   ├── pyproject.toml                # Python dependencies (Poetry)
│   └── apps/demo_cli.py              # Python utilities
├── scripts/
│   ├── configure.sh                  # Environment setup script
│   ├── build.sh                      # Build wrapper
│   ├── run_a55.sh                    # A55 deployment script
│   ├── flash_m33.sh                  # M33 flashing script
│   └── setup_env.sh                  # Environment variables
├── toolchains/
│   ├── aarch64-imx93.cmake           # A55 cross-compile toolchain
│   └── arm-m33-none-eabi.cmake       # M33 cross-compile toolchain
└── docs/
    ├── CROSS_COMPILER_SETUP.md       # Toolchain installation guide
    └── DOCKER_SETUP.md               # Docker usage documentation
```

## Build System Details

### What Happens During Configuration?

When you run `make configure`:

1. **Poetry Setup**: Installs Python dependencies and creates `.venv` in `python/`
2. **Build Tools**: Installs cmake and conan via pip into the venv
3. **Conan Profiles**: Auto-generates profiles for A55 (`build/.conan_profile_a55`) and M33 (`build/.conan_profile_m33`)
4. **CMake Configuration**: Configures the build system with Unix Makefiles generator

### CMake Generator: Why Unix Makefiles?

This project uses **Unix Makefiles** instead of Ninja to avoid CMake reconfiguration loops. During development, Ninja's dependency tracking caused infinite reconfiguration cycles. Unix Makefiles provides:
- Reliable dependency tracking without loops
- Standard GNU Make compatibility
- Sufficient performance for this project size
- No additional tool dependencies

### Conan Integration

Conan is configured but **dependency installation is currently disabled** to simplify builds. To enable:
1. Uncomment the `conan install` line in `scripts/configure.sh`
2. Add your C++ dependencies to `conanfile.py`
3. Test thoroughly to ensure no build issues

### Cross-Compiler Setup

- **A55**: Requires `aarch64-linux-gnu-*` toolchain (from apt, Linaro, or Yocto SDK)
- **M33**: Requires `arm-none-eabi-*` toolchain (from apt or ARM official downloads)
- **Native**: No cross-compilers needed - uses system gcc/g++

Toolchain files include fallback logic to use native compilers when cross-compilers aren't available.

See `docs/CROSS_COMPILER_SETUP.md` for detailed installation instructions.

## Development Workflow

### Adding New Applications

```bash
# Create new application directory
mkdir -p apps/a55/my_app
cd apps/a55/my_app

# Create CMakeLists.txt
cat > CMakeLists.txt << 'EOF'
add_executable(my_app main.cpp)
EOF

# Create source file
cat > main.cpp << 'EOF'
#include <iostream>
int main() {
    std::cout << "My App!" << std::endl;
    return 0;
}
EOF

# Add to parent CMakeLists.txt
echo "add_subdirectory(apps/a55/my_app)" >> CMakeLists.txt

# Build
make configure TARGET=native && make build TARGET=native
```

### Adding Drivers

Place hardware-specific drivers in `drivers/a55/` or `drivers/m33/` and reference them from your application's CMakeLists.txt.

### Testing Changes

```bash
# Quick iteration cycle with native build
make clean
make configure TARGET=native
make build TARGET=native
./build/native/apps/a55/hello_app/hello_a55

# Test on actual hardware
make configure TARGET=a55
make build TARGET=a55
make run-a55 HOST=192.168.1.100
```

## Troubleshooting

### Clock Skew Warning

If you see "File has modification time X s in the future", your system time may need adjustment:
```bash
timedatectl status
# If needed: sudo timedatectl set-ntp true
```

### Cross-Compiler Not Found

If builds fail with "compiler not found":
1. Verify toolchain installation: `which aarch64-linux-gnu-gcc`
2. Check toolchain paths in `scripts/setup_env.sh`
3. See `docs/CROSS_COMPILER_SETUP.md` for installation help
4. Or use Docker: `make run-docker && make docker-shell`

### CMake Configuration Errors

```bash
# Clean and reconfigure
make clean
rm -rf python/.venv
make configure TARGET=native
```

## Documentation

- **CROSS_COMPILER_SETUP.md**: Step-by-step toolchain installation (apt, Linaro, Yocto SDK)
- **DOCKER_SETUP.md**: Container-based development workflow

## Next Steps

1. **Explore examples**: Check `apps/a55/hello_app/` and `apps/m33/blinky/`
2. **Add your code**: Create new applications in `apps/`
3. **Implement drivers**: Add hardware drivers in `drivers/`
4. **Test locally**: Use `TARGET=native` for rapid iteration
5. **Deploy to board**: Use `TARGET=a55` or `TARGET=m33` for production builds

## License

[Your License Here]
