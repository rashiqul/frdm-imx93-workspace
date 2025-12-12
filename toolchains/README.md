# Toolchain Files

This directory contains CMake toolchain files and optionally downloaded cross-compilers.

## CMake Toolchain Files

- `aarch64-imx93.cmake` - A55 (Cortex-A55) ARMv8-A cross-compilation
- `arm-m33-none-eabi.cmake` - M33 (Cortex-M33) ARMv8-M bare-metal

## Downloaded Toolchains (Optional)

You can place downloaded toolchains in `toolchains/nxp/` for easy access:

### Current Setup

**NXP ARMv8 Bare-Metal Compiler:**
- Location: `toolchains/nxp/gcc-10.2.0-Earmv8GCC-eabi/`
- Binary path: `toolchains/nxp/gcc-10.2.0-Earmv8GCC-eabi/x86_64-linux/bin/`
- Compiler: `aarch64-none-elf-gcc`

**To use it:**
```bash
export ARM_NONE_EABI_BIN=$(pwd)/toolchains/nxp/gcc-10.2.0-Earmv8GCC-eabi/x86_64-linux/bin
make configure TARGET=m33
make build TARGET=m33
```

**Note:** The `toolchains/nxp/` directory is in `.gitignore` since toolchains are large binaries.

## System Compilers (Recommended)

For simplicity, use system-installed compilers:

```bash
# A55
sudo apt install gcc-aarch64-linux-gnu g++-aarch64-linux-gnu

# M33
sudo apt install gcc-arm-none-eabi binutils-arm-none-eabi
```

The CMake toolchain files will auto-discover them!
