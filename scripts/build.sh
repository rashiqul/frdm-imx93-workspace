#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${TARGET:-a55}"
BUILD_DIR="${ROOT_DIR}/build/${TARGET}"

# Use cmake from Poetry venv if available
POETRY_VENV="${ROOT_DIR}/python/.venv"
if [[ -d "${POETRY_VENV}" ]]; then
  export PATH="${POETRY_VENV}/bin:${PATH}"
fi

cmake --build "${BUILD_DIR}" --parallel
echo "Built ${TARGET} (artifacts in ${BUILD_DIR})"
