#!/usr/bin/env bash
set -euo pipefail

# Usage: scripts/serial_connect.sh /dev/ttyACM0 115200
# Defaults: DEVICE=${DEVICE:-/dev/ttyACM0}, BAUD=${BAUD:-115200}

DEVICE="${1:-${DEVICE:-/dev/ttyACM0}}"
BAUD="${2:-${BAUD:-115200}}"

if command -v picocom >/dev/null 2>&1; then
  echo "Connecting with picocom on ${DEVICE} at ${BAUD}..."
  exec picocom "${DEVICE}" -b "${BAUD}" --imap lfcrlf --omap crlf --nolock
elif command -v minicom >/dev/null 2>&1; then
  echo "Connecting with minicom on ${DEVICE} at ${BAUD}..."
  echo "Tip: configure minicom: minicom -s (Serial port setup)"
  exec minicom -D "${DEVICE}" -b "${BAUD}"
elif command -v screen >/dev/null 2>&1; then
  echo "Connecting with screen on ${DEVICE} at ${BAUD}... (Ctrl-A \ followed by k to kill)"
  exec screen "${DEVICE}" "${BAUD}"
else
  echo "ERROR: Install a serial terminal (picocom/minicom/screen)."
  echo "  Ubuntu: sudo apt-get install -y picocom"
  exit 1
fi
