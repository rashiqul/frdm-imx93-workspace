#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build/a55"
BIN="${BUILD_DIR}/apps/a55/hello_app/hello_a55"

HOST="${HOST:-}"
DEST_PATH="${DEST_PATH:-/tmp/hello_a55}"
SSH_OPTS="${SSH_OPTS:-}"

if [[ -z "${HOST}" ]]; then
  echo "Usage: HOST=<board-host-or-ip> scripts/run_a55.sh"
  exit 1
fi

scp ${SSH_OPTS} "${BIN}" "root@${HOST}:${DEST_PATH}"
ssh ${SSH_OPTS} "root@${HOST}" "chmod +x ${DEST_PATH} && ${DEST_PATH}"
