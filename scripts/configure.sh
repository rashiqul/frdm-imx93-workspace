#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../" && pwd)"
TARGET="${TARGET:-a55}"
BUILD_DIR="${ROOT_DIR}/build/${TARGET}"

source "${ROOT_DIR}/scripts/setup_env.sh"

# Python deps + build tools (cmake, ninja, conan)
if command -v poetry >/dev/null 2>&1; then
  echo "Installing Python dependencies..."
  (cd "${ROOT_DIR}/python" && poetry install)
  # Use tools from Poetry venv
  POETRY_VENV="${ROOT_DIR}/python/.venv"
  export PATH="${POETRY_VENV}/bin:${PATH}"
  
  # Install build tools in the venv using pip (workaround for Poetry metadata issues)
  echo "Installing build tools (cmake, ninja, conan) in venv..."
  if [ -f "${POETRY_VENV}/bin/pip" ]; then
    "${POETRY_VENV}/bin/pip" install -q cmake ninja conan
  else
    echo "Warning: pip not found in venv, trying direct install..."
    python3 -m pip install --user -q cmake ninja conan 2>/dev/null || true
  fi
else
  echo "ERROR: Poetry not found. Install via: pipx install poetry"
  exit 1
fi

# Create/detect Conan profiles
if command -v conan >/dev/null 2>&1; then
  echo "Setting up Conan profiles..."
  
  # Detect default profile if not exists
  if ! conan profile show default &>/dev/null; then
    echo "Creating default Conan profile..."
    conan profile detect --force
  fi
  
  mkdir -p "${ROOT_DIR}/build"
  
  # Create A55 profile (cross-compile for aarch64-linux)
  cat > "${ROOT_DIR}/build/.conan_profile_a55" <<EOF
[settings]
os=Linux
arch=armv8
compiler=gcc
compiler.version=11
compiler.libcxx=libstdc++11
compiler.cppstd=17
build_type=Release
EOF
  
  # Create M33 profile (bare-metal)
  cat > "${ROOT_DIR}/build/.conan_profile_m33" <<EOF
[settings]
os=baremetal
arch=armv7
compiler=gcc
compiler.version=11
compiler.libcxx=libstdc++11
compiler.cppstd=17
build_type=Release
EOF
  
  # Select profile based on target
  if [[ "${TARGET}" == "a55" ]]; then
    PROFILE_FILE="${ROOT_DIR}/build/.conan_profile_a55"
  else
    PROFILE_FILE="${ROOT_DIR}/build/.conan_profile_m33"
  fi
  
  # Install Conan dependencies (skipped for now to avoid CMake toolchain conflicts)
  echo "Skipping Conan dependencies for now..."
  #conan install . --output-folder=build/conan \
  #  --profile "${PROFILE_FILE}" \
  #  --build=missing || echo "Note: Conan install may fail for cross-compile targets without proper profiles"
else
  echo "WARNING: Conan not found in Poetry venv (optional)"
fi

mkdir -p "${BUILD_DIR}"
pushd "${BUILD_DIR}" >/dev/null

if [[ "${TARGET}" == "native" ]]; then
  echo "Configuring for native build (local testing)..."
  cmake -G "Unix Makefiles" \
    -DBUILD_A55=ON -DBUILD_M33=OFF \
    "${ROOT_DIR}"
elif [[ "${TARGET}" == "a55" ]]; then
  echo "Configuring for A55 cross-compile..."
  cmake -G "Unix Makefiles" \
    -DCMAKE_TOOLCHAIN_FILE="${ROOT_DIR}/toolchains/aarch64-imx93.cmake" \
    -DBUILD_A55=ON -DBUILD_M33=OFF \
    "${ROOT_DIR}"
elif [[ "${TARGET}" == "m33" ]]; then
  echo "Configuring for M33 cross-compile..."
  cmake -G "Unix Makefiles" \
    -DCMAKE_TOOLCHAIN_FILE="${ROOT_DIR}/toolchains/arm-m33-none-eabi.cmake" \
    -DBUILD_A55=OFF -DBUILD_M33=ON \
    "${ROOT_DIR}"
else
  echo "Unknown TARGET=${TARGET}. Valid targets: native, a55, m33"; exit 2
fi

popd >/dev/null
echo "Configured ${TARGET} in ${BUILD_DIR}"

# Create symlink to compile_commands.json for VSCode IntelliSense
if [[ -f "${BUILD_DIR}/compile_commands.json" ]]; then
  ln -sf "${BUILD_DIR}/compile_commands.json" "${ROOT_DIR}/compile_commands.json"
  echo "Created symlink: compile_commands.json -> ${BUILD_DIR}/compile_commands.json"
fi
