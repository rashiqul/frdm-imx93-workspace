# Docker Development Environment

This directory contains Docker configuration for building imx93-apps-drivers with all required cross-compilers pre-installed.

## Quick Start

### 1. Build and start the container

```bash
docker-compose up -d
```

### 2. Enter the container

```bash
docker-compose exec imx93-dev bash
```

### 3. Build your project

Inside the container:

```bash
# Configure and build for native (testing)
make configure TARGET=native
make build TARGET=native
./build/native/apps/a55/hello_app/hello_a55

# Configure and build for A55 (cross-compile)
make configure TARGET=a55
make build TARGET=a55

# Configure and build for M33 (cross-compile)
make configure TARGET=m33
make build TARGET=m33
```

## What's Included

The Docker image includes:

- **Base tools**: CMake, Ninja, Git, Python 3, Poetry
- **A55 toolchain**: `gcc-aarch64-linux-gnu` (for ARM Cortex-A55)
- **M33 toolchain**: `gcc-arm-none-eabi` (for ARM Cortex-M33)
- **Build tools**: Conan 2.x for C/C++ dependencies
- **Python tools**: Poetry environment with all dependencies

## Usage Patterns

### Interactive Development

```bash
# Start container in background
docker-compose up -d

# Open a shell
docker-compose exec imx93-dev bash

# Work inside the container...
# Build, test, etc.

# Exit when done
exit

# Stop container
docker-compose down
```

### One-off Commands

```bash
# Run a single command without entering the container
docker-compose run --rm imx93-dev make configure TARGET=a55
docker-compose run --rm imx93-dev make build TARGET=a55
```

### Rebuilding the Image

If you modify the Dockerfile:

```bash
# Rebuild the image
docker-compose build

# Or force rebuild without cache
docker-compose build --no-cache
```

## Volume Mounts

The docker-compose configuration uses volumes to persist data:

- **Project files**: Mounted at `/workspace` (read/write)
- **Build artifacts**: Cached in `build-cache` volume
- **Poetry cache**: Cached in `poetry-cache` volume
- **Conan cache**: Cached in `conan-cache` volume

This means:
- Changes you make in the container are reflected on your host
- Build artifacts persist between container restarts
- Dependencies don't need to be re-downloaded

## Troubleshooting

### Container won't start

```bash
# Check logs
docker-compose logs

# Remove and recreate
docker-compose down -v
docker-compose up -d
```

### Permission issues

If you encounter permission issues with build artifacts:

```bash
# Run as your user instead of root
docker-compose run --rm --user $(id -u):$(id -g) imx93-dev bash
```

### Clean rebuild

```bash
# Remove all containers and volumes
docker-compose down -v

# Remove the image
docker rmi imx93-apps-drivers-imx93-dev

# Rebuild from scratch
docker-compose build --no-cache
docker-compose up -d
```

## Advanced Configuration

### Custom Toolchain Versions

Edit the `Dockerfile` to use specific toolchain versions:

```dockerfile
# Example: Install Linaro toolchain instead of system package
RUN wget https://releases.linaro.org/.../aarch64-linux-gnu.tar.xz && \
    tar -xf aarch64-linux-gnu.tar.xz -C /opt/ && \
    rm aarch64-linux-gnu.tar.xz
ENV AARCH64_TOOLCHAIN=/opt/gcc-linaro-.../bin
```

### Adding Development Tools

Add tools to the Dockerfile:

```dockerfile
RUN apt-get update && apt-get install -y \
    gdb-multiarch \
    openocd \
    minicom \
    && rm -rf /var/lib/apt/lists/*
```

### Resource Limits

Uncomment the `deploy` section in `docker-compose.yml` to limit CPU and memory:

```yaml
deploy:
  resources:
    limits:
      cpus: '4'
      memory: 8G
```

## VS Code Integration

To use with VS Code Remote Containers:

1. Install the "Dev Containers" extension
2. Add `.devcontainer/devcontainer.json`:

```json
{
  "name": "IMX93 Development",
  "dockerComposeFile": "../docker-compose.yml",
  "service": "imx93-dev",
  "workspaceFolder": "/workspace",
  "extensions": [
    "ms-vscode.cpptools",
    "ms-vscode.cmake-tools",
    "ms-python.python"
  ]
}
```

3. Open the project in VS Code
4. Click "Reopen in Container" when prompted

## CI/CD Integration

Use the Docker image in CI pipelines:

### GitHub Actions

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build with Docker
        run: |
          docker-compose run --rm imx93-dev make configure TARGET=a55
          docker-compose run --rm imx93-dev make build TARGET=a55
```

### GitLab CI

```yaml
build:
  image: docker/compose:latest
  services:
    - docker:dind
  script:
    - docker-compose run --rm imx93-dev make configure TARGET=a55
    - docker-compose run --rm imx93-dev make build TARGET=a55
```

