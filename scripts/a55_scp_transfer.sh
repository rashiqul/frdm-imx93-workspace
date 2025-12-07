#!/usr/bin/env bash
set -euo pipefail

# Usage: scripts/a55_scp_transfer.sh <board-ip-or-hostname>
# Simple SCP-based transfer (requires network connectivity)

HOST="${1:-${HOST:-}}"
if [ -z "${HOST}" ]; then
  echo "ERROR: No host specified."
  echo "Usage: $0 <board-ip-or-hostname>"
  echo "Example: $0 192.168.1.100"
  echo "   Or:   make scp-a55 HOST=192.168.1.100"
  exit 1
fi

BIN_PATH="build/a55/apps/a55/hello_app/hello_a55"
if [ ! -f "${BIN_PATH}" ]; then
  echo "ERROR: ${BIN_PATH} not found. Run 'make configure TARGET=a55 && make build TARGET=a55' first."
  exit 1
fi

USER="${USER:-root}"
DEST_PATH="${DEST_PATH:-/tmp/hello_a55}"

echo "========================================"
echo "SCP Transfer Helper"
echo "========================================"
echo "Host:   ${HOST}"
echo "User:   ${USER}"
echo "File:   ${BIN_PATH}"
echo "Dest:   ${DEST_PATH}"
echo ""

scp "${BIN_PATH}" "${USER}@${HOST}:${DEST_PATH}"

if [ $? -eq 0 ]; then
  echo ""
  echo "✓ Transfer completed successfully!"
  echo ""
  echo "To run on the board:"
  echo "  ssh ${USER}@${HOST}"
  echo "  chmod +x ${DEST_PATH}"
  echo "  ${DEST_PATH}"
else
  echo ""
  echo "✗ Transfer failed"
  echo ""
  echo "Check:"
  echo "- Network connectivity: ping ${HOST}"
  echo "- SSH access: ssh ${USER}@${HOST}"
  echo "- Board IP address is correct"
fi
