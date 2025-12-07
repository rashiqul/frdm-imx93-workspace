#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build/m33"
ELF="${BUILD_DIR}/apps/m33/blinky/blinky_m33"

# Placeholder: choose one method and implement for your setup.

echo "== M33 flash stub =="
echo "ELF: ${ELF}"
echo "Options:"
echo "  * Using NXP u-boot/uuu (SDP) to load/flash"
echo "  * Using pyOCD / OpenOCD via SWD/JTAG"
echo "Please edit scripts/flash_m33.sh for your environment."
exit 1
