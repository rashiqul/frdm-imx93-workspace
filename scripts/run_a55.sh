#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Accept binary path as argument or use default
BIN="${1:-}"
if [[ -z "${BIN}" ]]; then
  # Default to hello_app if no argument provided
  BUILD_DIR="${ROOT_DIR}/build/a55"
  BIN="${BUILD_DIR}/apps/a55/hello_app/hello_a55"
fi

# Check if binary exists
if [[ ! -f "${BIN}" ]]; then
  echo "ERROR: Binary not found: ${BIN}"
  echo ""
  echo "Usage: $0 [binary-path]"
  echo "   Or: HOST=<host> USER=<user> $0 [binary-path]"
  echo ""
  echo "If no binary path provided, defaults to: build/a55/apps/a55/hello_app/hello_a55"
  exit 1
fi

# Get binary name for destination
BIN_NAME=$(basename "${BIN}")

# Check if HOST is set (with or without a value)
if [[ ! -v HOST ]]; then
  # HOST not set at all - use default
  HOST="imx93.local"
elif [[ -z "${HOST}" ]]; then
  # HOST explicitly set to empty - show UART hint
  echo "INFO: No HOST specified for network deployment."
  echo ""
  echo "To deploy via SSH/network:"
  echo "  HOST=<board-ip> $0 ${BIN}"
  echo ""
  echo "For UART console access:"
  echo "  make uart DEVICE=/dev/ttyACM0"
  echo ""
  echo "Then manually transfer files as needed."
  exit 0
fi

# Configuration with sensible defaults
USER="${USER:-rashiqul}"
DEST_PATH="${DEST_PATH:-/tmp/${BIN_NAME}}"
SSH_OPTS="${SSH_OPTS:-}"
DEPLOY="${DEPLOY:-scp}"  # Options: scp, rsync

echo "Deploying to ${USER}@${HOST}:${DEST_PATH} using ${DEPLOY}..."

# Deploy using selected method
if [[ "${DEPLOY}" == "rsync" ]]; then
  if ! command -v rsync &>/dev/null; then
    echo "WARNING: rsync not found, falling back to scp"
    DEPLOY="scp"
  else
    rsync -avz ${SSH_OPTS} "${BIN}" "${USER}@${HOST}:${DEST_PATH}"
  fi
fi

if [[ "${DEPLOY}" == "scp" ]]; then
  scp ${SSH_OPTS} "${BIN}" "${USER}@${HOST}:${DEST_PATH}"
fi

# Execute the binary on the target
echo "Executing ${DEST_PATH} on target..."
ssh ${SSH_OPTS} "${USER}@${HOST}" "chmod +x ${DEST_PATH} && ${DEST_PATH}"
