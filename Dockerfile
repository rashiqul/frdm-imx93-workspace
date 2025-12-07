FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install base dependencies
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
    && rm -rf /var/lib/apt/lists/*

# Install cross-compilers for A55 (aarch64)
RUN apt-get update && apt-get install -y \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu \
    && rm -rf /var/lib/apt/lists/*

# Install ARM Cortex-M toolchain for M33
RUN apt-get update && apt-get install -y \
    gcc-arm-none-eabi \
    binutils-arm-none-eabi \
    newlib-arm-none-eabi \
    libnewlib-arm-none-eabi \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry for Python dependency management
RUN pipx install poetry && pipx ensurepath
ENV PATH="/root/.local/bin:${PATH}"

# Set up environment variables for toolchains
ENV AARCH64_TOOLCHAIN=/usr/bin
ENV ARM_NONE_EABI_BIN=/usr/bin

# Set working directory
WORKDIR /workspace

# Copy project files
COPY . /workspace/

# Install Python dependencies and build tools
RUN cd /workspace/python && poetry install

# Expose any ports if needed (e.g., for debugging)
# EXPOSE 8080

# Default command
CMD ["/bin/bash"]
