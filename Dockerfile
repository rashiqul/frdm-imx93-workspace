FROM ubuntu:22.04 AS base

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install base dependencies in one layer
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    python3 \
    python3-pip \
    python3-venv \
    pipx \
    pkg-config \
    libssl-dev \
    ca-certificates \
    # A55 cross-compilers (aarch64)
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu \
    # M33 ARM Cortex-M toolchain
    gcc-arm-none-eabi \
    binutils-arm-none-eabi \
    libnewlib-arm-none-eabi \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry for Python dependency management
RUN pipx install poetry && pipx ensurepath
ENV PATH="/root/.local/bin:${PATH}"

# Set up environment variables for toolchains (auto-discovered but explicit here)
ENV AARCH64_TOOLCHAIN=/usr/bin
ENV ARM_NONE_EABI_BIN=/usr/bin

# Set working directory
WORKDIR /workspace

# ============================================================================
# Builder stage: for running builds
# ============================================================================
FROM base AS builder

# Copy only dependency files first (for caching)
COPY python/pyproject.toml python/poetry.lock* /workspace/python/

# Install Python dependencies
RUN cd /workspace/python && \
    poetry install --no-root && \
    poetry run pip install cmake ninja conan

# Copy the rest of the project
COPY . /workspace/

# Verify toolchains are available
RUN aarch64-linux-gnu-gcc --version && \
    arm-none-eabi-gcc --version && \
    echo "✅ Both toolchains ready"

# ============================================================================
# Development stage: for interactive development
# ============================================================================
FROM builder AS dev

# Add helpful development tools
RUN apt-get update && apt-get install -y \
    vim \
    nano \
    htop \
    tree \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]

# Install Python dependencies and build tools
RUN cd /workspace/python && poetry install

# Expose any ports if needed (e.g., for debugging)
# EXPOSE 8080

# Default command
CMD ["/bin/bash"]
