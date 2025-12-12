# Toolchain for M33 bare‑metal (arm‑none‑eabi) with smart discovery
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Skip CMake's compiler test for bare-metal (it will fail without startup/linker script)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Priority 1: Explicit ARM_NONE_EABI_BIN environment variable
if(DEFINED ENV{ARM_NONE_EABI_BIN} AND NOT "$ENV{ARM_NONE_EABI_BIN}" STREQUAL "")
  set(TOOLCHAIN_BIN $ENV{ARM_NONE_EABI_BIN})
  set(CMAKE_C_COMPILER   ${TOOLCHAIN_BIN}/arm-none-eabi-gcc CACHE FILEPATH "" FORCE)
  set(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN}/arm-none-eabi-g++ CACHE FILEPATH "" FORCE)
  set(CMAKE_ASM_COMPILER ${TOOLCHAIN_BIN}/arm-none-eabi-gcc CACHE FILEPATH "" FORCE)
  set(CMAKE_AR           ${TOOLCHAIN_BIN}/arm-none-eabi-ar  CACHE FILEPATH "" FORCE)
  set(CMAKE_RANLIB       ${TOOLCHAIN_BIN}/arm-none-eabi-ranlib CACHE FILEPATH "" FORCE)
  message(STATUS "M33: Using ARM cross-compiler from ARM_NONE_EABI_BIN: ${TOOLCHAIN_BIN}")

# Priority 2: Try to find arm-none-eabi-gcc in PATH
else()
  find_program(ARM_NONE_EABI_GCC arm-none-eabi-gcc)
  if(ARM_NONE_EABI_GCC)
    get_filename_component(TOOLCHAIN_BIN ${ARM_NONE_EABI_GCC} DIRECTORY)
    set(CMAKE_C_COMPILER   ${TOOLCHAIN_BIN}/arm-none-eabi-gcc CACHE FILEPATH "" FORCE)
    set(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN}/arm-none-eabi-g++ CACHE FILEPATH "" FORCE)
    set(CMAKE_ASM_COMPILER ${TOOLCHAIN_BIN}/arm-none-eabi-gcc CACHE FILEPATH "" FORCE)
    set(CMAKE_AR           ${TOOLCHAIN_BIN}/arm-none-eabi-ar  CACHE FILEPATH "" FORCE)
    set(CMAKE_RANLIB       ${TOOLCHAIN_BIN}/arm-none-eabi-ranlib CACHE FILEPATH "" FORCE)
    message(STATUS "M33: Using system ARM cross-compiler: ${ARM_NONE_EABI_GCC}")

  # Priority 3: Error with helpful installation instructions
  else()
    message(FATAL_ERROR
      "====================================================================\n"
      "M33 ARM embedded cross-compiler not found!\n"
      "====================================================================\n"
      "\n"
      "Please install the ARM bare-metal toolchain using ONE of these methods:\n"
      "\n"
      "Option 1 - Ubuntu/Debian package manager (easiest):\n"
      "  sudo apt update\n"
      "  sudo apt install -y gcc-arm-none-eabi binutils-arm-none-eabi\n"
      "\n"
      "  Note: Package 'libnewlib-arm-none-eabi' will be installed automatically.\n"
      "\n"
      "Option 2 - ARM official toolchain (latest features):\n"
      "  # Download from: https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads\n"
      "  # Extract and add to PATH, or set ARM_NONE_EABI_BIN:\n"
      "  export ARM_NONE_EABI_BIN=/opt/toolchains/arm-gnu-toolchain/bin\n"
      "\n"
      "Option 3 - MCUXpresso IDE toolchain:\n"
      "  # If you have NXP MCUXpresso installed:\n"
      "  export ARM_NONE_EABI_BIN=~/MCUXpressoIDE_11.8.0/ide/tools/bin\n"
      "\n"
      "After installation, verify with:\n"
      "  arm-none-eabi-gcc --version\n"
      "\n"
      "Then re-run: make configure TARGET=m33\n"
      "\n"
      "See docs/CROSS_COMPILER_SETUP.md for more details.\n"
      "====================================================================\n"
    )
  endif()
endif()

# Cortex‑M33 flags (no OS for now)
set(COMMON_FLAGS "-mcpu=cortex-m33 -mthumb -O2 -ffunction-sections -fdata-sections")
set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   ${COMMON_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${COMMON_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--gc-sections")
