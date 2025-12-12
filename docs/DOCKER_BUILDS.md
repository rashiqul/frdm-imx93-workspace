# Docker-Based Builds

Build your i.MX93 applications in a reproducible Docker environment with all toolchains pre-installed.

## Benefits

✅ **Reproducible** - Same build environment everywhere  
✅ **No local setup** - All toolchains in container  
✅ **Team-friendly** - Everyone builds the same way  
✅ **CI/CD ready** - Perfect for automation  
✅ **Multi-target** - Both A55 and M33 in one container  
✅ **Automatic** - Just `make configure` and `make build`

## Prerequisites

Install Docker (one-time setup):
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose-plugin
sudo usermod -aG docker $USER
# Log out and back in for group changes

# Or follow: https://docs.docker.com/get-docker/
```

## Quick Start (Recommended Workflow)

### Option 1: Interactive Docker Shell (Recommended)

Launch Docker and work inside:
```bash
make run-docker

# You're now inside the Docker container!
# All toolchains are available

make configure TARGET=a55
make build TARGET=a55

make configure TARGET=m33  
make build TARGET=m33

# Check toolchains
aarch64-linux-gnu-gcc --version
arm-none-eabi-gcc --version

exit  # Leave Docker when done
```

### Option 2: Auto-Docker (From Outside Container)

Commands automatically use Docker if available:
```bash
# These run inside Docker automatically
make configure TARGET=a55
make build TARGET=a55

# No need to run 'make run-docker' first!
```

**Recommended**: Use Option 1 (interactive shell) for development.  
Use Option 2 for CI/CD or quick one-off builds.

## Docker vs Local Builds

| Aspect | Docker Build | Local Build |
|--------|-------------|-------------|
| Setup | One-time image build | Install toolchains locally |
| Reproducibility | 100% same everywhere | Depends on your system |
| Isolation | Complete | Uses your PATH/env |
| Speed | Slightly slower | Native speed |
| CI/CD | Perfect | Needs setup |

## Command Reference

### Docker Commands

```bash
make run-docker              # Launch interactive Docker shell (type 'exit' to quit)
make shell                   # Alias for run-docker
make configure TARGET=a55    # Auto-uses Docker if available
make build TARGET=a55        # Auto-uses Docker if available
make clean                   # Clean build artifacts
```

### Local Build (Without Docker)

If Docker isn't available or you prefer local builds:
```bash
make local-configure TARGET=a55
make local-build TARGET=a55
```

### Complete Workflow Examples

**Interactive development (recommended):**
```bash
make run-docker
# Now inside Docker:
make configure TARGET=a55
make build TARGET=a55
make configure TARGET=m33
make build TARGET=m33
exit
```

**One-off builds (from outside Docker):**
```bash
# These automatically use Docker if available
make configure TARGET=a55
make build TARGET=a55
```

**CI/CD pipeline:**
```bash
# Build all targets in one go
make configure TARGET=native && make build TARGET=native
make configure TARGET=a55 && make build TARGET=a55
make configure TARGET=m33 && make build TARGET=m33
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
