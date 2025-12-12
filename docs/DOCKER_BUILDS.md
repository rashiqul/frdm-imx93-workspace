# Docker-Based Builds

Build your i.MX93 applications in a reproducible Docker environment with all toolchains pre-installed.

## Benefits

✅ **Reproducible** - Same build environment everywhere  
✅ **No local setup** - All toolchains in container  
✅ **Team-friendly** - Everyone builds the same way  
✅ **CI/CD ready** - Perfect for automation  
✅ **Multi-target** - Both A55 and M33 in one container  

## Prerequisites

Install Docker:
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose-plugin
sudo usermod -aG docker $USER
# Log out and back in for group changes

# Or follow: https://docs.docker.com/get-docker/
```

## Quick Start

### 1. Build the Docker Image (One Time)
```bash
make docker-build
```

This creates an image with:
- Ubuntu 22.04 base
- GCC aarch64-linux-gnu (A55)
- GCC arm-none-eabi (M33)
- CMake, Poetry, Conan
- All build dependencies

### 2. Build Your Applications

**Build all targets:**
```bash
make docker-build-all
```

**Build specific target:**
```bash
make docker-configure TARGET=a55
make docker-compile TARGET=a55
```

**Interactive development:**
```bash
make docker-shell
# Now inside container:
make configure TARGET=a55
make build TARGET=a55
exit
```

## Docker vs Local Builds

| Aspect | Docker Build | Local Build |
|--------|-------------|-------------|
| Setup | One-time image build | Install toolchains locally |
| Reproducibility | 100% same everywhere | Depends on your system |
| Isolation | Complete | Uses your PATH/env |
| Speed | Slightly slower | Native speed |
| CI/CD | Perfect | Needs setup |

## Docker Commands Reference

```bash
# Build the Docker image
make docker-build

# Configure a target
make docker-configure TARGET=a55

# Compile a target
make docker-compile TARGET=m33

# Build all targets
make docker-build-all

# Interactive shell
make docker-shell

# Clean everything (including Docker)
make clean
docker rmi imx93-dev-env
```

## How It Works

### Multi-Stage Dockerfile

```
base stage:
  - Ubuntu 22.04
  - Both cross-compilers
  - Poetry for Python deps

builder stage:
  - Installs Python dependencies
  - Verifies toolchains
  - Ready to build

dev stage:
  - Adds development tools
  - Interactive bash shell
```

### Volume Mounts

Build artifacts are persisted locally:
- `./build` - CMake build output
- `./.venv` - Python virtual environment  
- Volumes for caches (Poetry, Conan)

## Troubleshooting

### "Cannot connect to Docker daemon"
```bash
sudo systemctl start docker
sudo usermod -aG docker $USER
# Log out and back in
```

### "Permission denied" errors
```bash
# Make sure you're in the docker group
groups | grep docker

# If not, add yourself:
sudo usermod -aG docker $USER
newgrp docker
```

### Build is slow
First build downloads packages. Subsequent builds use cache.

### Out of disk space
```bash
# Clean up old images and containers
docker system prune -a
```

## CI/CD Integration

Example GitHub Actions:
```yaml
name: Docker Build
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build all targets
        run: make docker-build-all
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: binaries
          path: build/
```

## Advanced Usage

### Custom toolchain in Docker
Edit `Dockerfile` to add NXP-specific toolchains:
```dockerfile
# Download and install NXP SDK
ADD toolchains/nxp/ /opt/nxp-toolchains/
ENV PATH="/opt/nxp-toolchains/bin:${PATH}"
```

### Build with specific compiler version
Modify the Dockerfile base image or toolchain packages.

### Share build cache across machines
Use Docker volumes or bind mounts for shared cache.

## See Also

- [Cross-Compiler Setup](CROSS_COMPILER_SETUP.md) - For local builds
- [README.md](../README.md) - Main documentation
