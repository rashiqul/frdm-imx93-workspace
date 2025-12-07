#!/usr/bin/env bash
# Edit these paths for your host!
# A55 toolchain (Yocto SDK or Linaro) - leave empty to use system or native fallback
export AARCH64_TOOLCHAIN=${AARCH64_TOOLCHAIN:-}
# M33 toolchain (GNU Arm Embedded) - leave empty to use system or native fallback
export ARM_NONE_EABI_BIN=${ARM_NONE_EABI_BIN:-}

# Optional: point Conan to a profile (aarch64) and JFrog remote
export CONAN_PROFILE=${CONAN_PROFILE:-default}
# Example to add a remote once:
# conan remote add my_artifactory https://mycompany.jfrog.io/artifactory/api/conan/conan-local

# Poetry virtualenv handling
export POETRY_VIRTUALENVS_IN_PROJECT=true
