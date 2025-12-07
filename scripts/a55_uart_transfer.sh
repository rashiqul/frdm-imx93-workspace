#!/usr/bin/env bash
set -euo pipefail

# Usage: scripts/a55_uart_transfer.sh /dev/ttyACM0 115200
# Requires: host has lrzsz installed (sz), board has rz available.
# 
# This script sends the A55 hello binary to the board via ZMODEM (sz/rz).
# It uses a simple approach: configure the serial port, then run sz directly.

DEVICE="${1:-${DEVICE:-/dev/ttyACM0}}"
BAUD="${2:-${BAUD:-115200}}"

BIN_PATH="build/a55/apps/a55/hello_app/hello_a55"
if [ ! -f "${BIN_PATH}" ]; then
  echo "ERROR: ${BIN_PATH} not found. Run 'make configure TARGET=a55 && make build TARGET=a55' first."
  exit 1
fi

if ! command -v sz >/dev/null 2>&1; then
  echo "ERROR: 'sz' not found. Install lrzsz: sudo apt-get install -y lrzsz"
  exit 1
fi

if ! command -v stty >/dev/null 2>&1; then
  echo "ERROR: 'stty' not found (should be in coreutils)."
  exit 1
fi

# Check device exists and is accessible
if [ ! -c "${DEVICE}" ]; then
  echo "ERROR: ${DEVICE} is not a character device. Check connection and path."
  echo "Try: ls -l /dev/ttyUSB* or /dev/ttyACM*"
  exit 1
fi

echo "========================================"
echo "UART File Transfer Helper"
echo "========================================"
echo "Device: ${DEVICE}"
echo "Baud:   ${BAUD}"
echo "File:   ${BIN_PATH}"
echo ""
echo "INSTRUCTIONS:"
echo "1. Open a serial console to your board in another terminal:"
echo "   make uart DEVICE=${DEVICE} BAUD=${BAUD}"
echo ""
echo "2. Log into the board (if not already logged in)"
echo ""
echo "3. On the board shell, run EXACTLY:"
echo "   rz -b -E"
echo "   (The -b is for binary, -E for escaping)"
echo ""
echo "4. IMPORTANT: You should see 'rz' waiting (cursor stops blinking)"
echo "   If you see any other output, rz is NOT ready!"
echo ""
echo "5. Press Enter here ONLY when rz is running and waiting..."
echo ""
read -p "Ready? Press Enter to send ${BIN_PATH}..." _

# Configure the serial port for raw mode
stty -F "${DEVICE}" "${BAUD}" raw -echo -echoe -echok

# Send the file using sz (zmodem send)
# -b: binary mode
# -e: escape control characters
echo ""
echo "Sending file via ZMODEM..."
sz -b -e "${BIN_PATH}" < "${DEVICE}" > "${DEVICE}"

RESULT=$?
echo ""
if [ ${RESULT} -eq 0 ]; then
  echo "✓ Transfer completed successfully!"
  echo ""
  echo "On the board, run:"
  echo "  chmod +x hello_a55"
  echo "  ./hello_a55"
else
  echo "✗ Transfer failed with exit code ${RESULT}"
  echo ""
  echo "Common issues:"
  echo ""
  echo "1. 'rz' not running on board:"
  echo "   - Make sure you logged into the board shell first"
  echo "   - Run 'rz -b -E' and wait for it to start (cursor stops)"
  echo "   - Then press Enter in this terminal to send"
  echo ""
  echo "2. Board doesn't have 'rz' installed:"
  echo "   - Install lrzsz: apt-get install lrzsz (on Debian/Ubuntu)"
  echo "   - Or use alternative method (see README)"
  echo ""
  echo "3. Serial interference:"
  echo "   - Close other programs accessing ${DEVICE}"
  echo "   - Try: fuser ${DEVICE} to see what's using it"
  echo ""
  echo "4. Wrong device:"
  echo "   - Try other device: make run-a55-uart DEVICE=/dev/ttyACM1"
  echo ""
  echo "Alternative: Use scp if network is available:"
  echo "  scp ${BIN_PATH} root@<board-ip>:/tmp/"
fi
