# Cross-Compiler Setup Guide

This guide explains how to install and configure cross-compilers for building applications targeting the FRDM-i.MX93 board.

## Table of Contents
- [A55 (ARM Cortex-A55) Toolchain](#a55-toolchain)
- [M33 (ARM Cortex-M33) Toolchain](#m33-toolchain)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

---

## A55 Toolchain

The A55 cores run Linux, so we need an `aarch64-linux-gnu` cross-compiler.

### Option 1: Using Package Manager (Ubuntu/Debian)

```bash
# Install GCC cross-compiler for aarch64
sudo apt update
sudo apt install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu binutils-aarch64-linux-gnu

# Verify installation
aarch64-linux-gnu-gcc --version
```

### Option 2: Linaro Toolchain (Recommended for production)

```bash
# Download Linaro GCC toolchain
cd /tmp
wget https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz

# Extract to /opt
sudo mkdir -p /opt/toolchains
sudo tar -xf gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz -C /opt/toolchains/

# Create symlink for easier access
sudo ln -s /opt/toolchains/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu /opt/toolchains/aarch64-linux-gnu

# Add to PATH (add to ~/.bashrc for persistence)
export PATH=/opt/toolchains/aarch64-linux-gnu/bin:$PATH
```

### Option 3: Yocto SDK

If you have a Yocto build environment for i.MX93:

```bash
# Install the SDK from your Yocto build
cd <yocto-build-dir>
bitbake meta-toolchain

# Find the SDK installer
ls tmp/deploy/sdk/*.sh

# Run the installer
./tmp/deploy/sdk/fsl-imx-xwayland-glibc-x86_64-meta-toolchain-aarch64-toolchain-*.sh

# Source the environment
source /opt/fsl-imx-xwayland/<version>/environment-setup-aarch64-poky-linux
```

### Configuration

Edit `scripts/setup_env.sh` to point to your toolchain:

```bash
# For system-installed toolchain
export AARCH64_TOOLCHAIN=/usr/bin

# For Linaro toolchain
export AARCH64_TOOLCHAIN=/opt/toolchains/aarch64-linux-gnu/bin

# For Yocto SDK
export AARCH64_TOOLCHAIN=/opt/fsl-imx-xwayland/<version>/sysroots/x86_64-pokysdk-linux/usr/bin/aarch64-poky-linux
```

---

## M33 Toolchain

The M33 core runs bare-metal (no OS), so we need an `arm-none-eabi` toolchain.

### Option 1: ARM GNU Toolchain (Recommended)

```bash
# Download from ARM's official site
cd /tmp
wget https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz

# Extract to /opt
sudo mkdir -p /opt/toolchains
sudo tar -xf arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz -C /opt/toolchains/

# Create symlink
sudo ln -s /opt/toolchains/arm-gnu-toolchain-13.2.Rel1-x86_64-arm-none-eabi /opt/toolchains/arm-none-eabi

# Add to PATH
export PATH=/opt/toolchains/arm-none-eabi/bin:$PATH
```

### Option 2: Using Package Manager (Ubuntu/Debian)

```bash
# Install GCC ARM embedded toolchain
sudo apt update
sudo apt install -y gcc-arm-none-eabi binutils-arm-none-eabi newlib-arm-none-eabi

# Verify installation
arm-none-eabi-gcc --version
```

### Option 3: MCUXpresso IDE Toolchain

If you have NXP's MCUXpresso IDE installed:

```bash
# Toolchain is typically located at:
# Linux: ~/MCUXpressoIDE_<version>/ide/tools/bin
# Windows: C:\nxp\MCUXpressoIDE_<version>\ide\tools\bin

# Add to PATH
export PATH=~/MCUXpressoIDE_11.8.0/ide/tools/bin:$PATH
```

### Configuration

Edit `scripts/setup_env.sh` to point to your toolchain:

```bash
# For ARM official toolchain
export ARM_NONE_EABI_BIN=/opt/toolchains/arm-none-eabi/bin

# For system-installed toolchain
export ARM_NONE_EABI_BIN=/usr/bin

# For MCUXpresso
export ARM_NONE_EABI_BIN=~/MCUXpressoIDE_11.8.0/ide/tools/bin
```

---

## Verification

After installing and configuring the toolchains, verify they work:

### Test A55 Toolchain

```bash
# Source your environment
source scripts/setup_env.sh

# Check compiler
${AARCH64_TOOLCHAIN}/aarch64-linux-gnu-gcc --version

# Test compilation
echo 'int main() { return 0; }' > /tmp/test.c
${AARCH64_TOOLCHAIN}/aarch64-linux-gnu-gcc /tmp/test.c -o /tmp/test_a55
file /tmp/test_a55
# Should show: ELF 64-bit LSB executable, ARM aarch64
```

### Test M33 Toolchain

```bash
# Source your environment
source scripts/setup_env.sh

# Check compiler
${ARM_NONE_EABI_BIN}/arm-none-eabi-gcc --version

# Test compilation
echo 'int main() { return 0; }' > /tmp/test.c
${ARM_NONE_EABI_BIN}/arm-none-eabi-gcc -mcpu=cortex-m33 -mthumb /tmp/test.c -o /tmp/test_m33.elf
file /tmp/test_m33.elf
# Should show: ELF 32-bit LSB executable, ARM
```

### Test Full Build

```bash
# Configure and build for A55
make configure TARGET=a55
make build TARGET=a55

# Check the binary
file build/a55/apps/a55/hello_app/hello_a55

# Configure and build for M33
make configure TARGET=m33
make build TARGET=m33

# Check the binary
file build/m33/apps/m33/blinky/blinky_m33
```

---

## Troubleshooting

### Issue: "command not found" for cross-compiler

**Solution**: Ensure the toolchain directory is in your PATH:

```bash
# Check current PATH
echo $PATH

# Temporarily add to PATH
export PATH=/path/to/toolchain/bin:$PATH

# Permanently add to PATH (add to ~/.bashrc or ~/.zshrc)
echo 'export PATH=/path/to/toolchain/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

### Issue: "cannot find -lgcc" or missing libraries

**Solution**: For bare-metal (M33), ensure you have newlib installed:

```bash
# Ubuntu/Debian
sudo apt install newlib-arm-none-eabi libnewlib-arm-none-eabi

# Or use the complete ARM GNU toolchain which includes newlib
```

### Issue: Linker errors for M33

**Solution**: The M33 examples need a linker script. You'll need to:

1. Obtain a linker script for i.MX93 M33 from NXP SDK
2. Place it in `boards/imx93_m33.ld`
3. Update `apps/m33/blinky/CMakeLists.txt`:

```cmake
set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/boards/imx93_m33.ld)
target_link_options(blinky_m33 PRIVATE 
    "-T${LINKER_SCRIPT}"
    -Wl,-Map=blinky_m33.map
)
```

### Issue: Different GCC versions between host and cross-compiler

**Solution**: This is usually fine, but if you encounter ABI issues, try to match versions closer or use Conan's toolchain integration.

### Issue: Conan packages not compatible with cross-compilation

**Solution**: Build packages from source:

```bash
# Force building from source
conan install . --output-folder=build/conan \
    --profile build/.conan_profile_a55 \
    --build=missing --build="*"
```

---

## Additional Resources

- [ARM GNU Toolchain Downloads](https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads)
- [Linaro Toolchain Releases](https://releases.linaro.org/components/toolchain/binaries/)
- [NXP i.MX93 Documentation](https://www.nxp.com/products/processors-and-microcontrollers/arm-processors/i-mx-applications-processors/i-mx-9-processors:IMX9-PROCESSORS)
- [MCUXpresso IDE](https://www.nxp.com/design/software/development-software/mcuxpresso-software-and-tools-/mcuxpresso-integrated-development-environment-ide:MCUXpresso-IDE)

---

## Quick Reference

| Target | Compiler | Architecture | Typical Use |
|--------|----------|--------------|-------------|
| native | gcc/g++ | x86_64 | Local testing |
| a55 | aarch64-linux-gnu-gcc | ARMv8-A (64-bit) | Linux applications |
| m33 | arm-none-eabi-gcc | ARMv7-M (32-bit) | Bare-metal/RTOS |

