# Toolchain for A55 (ARMv8‑A, aarch64) cross‑compile with smart discovery
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# Priority 1: Explicit AARCH64_TOOLCHAIN environment variable
if(DEFINED ENV{AARCH64_TOOLCHAIN} AND NOT "$ENV{AARCH64_TOOLCHAIN}" STREQUAL "")
  set(TOOLCHAIN_BIN $ENV{AARCH64_TOOLCHAIN})
  set(CMAKE_C_COMPILER   ${TOOLCHAIN_BIN}/aarch64-linux-gnu-gcc CACHE FILEPATH "" FORCE)
  set(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN}/aarch64-linux-gnu-g++ CACHE FILEPATH "" FORCE)
  set(CMAKE_AR           ${TOOLCHAIN_BIN}/aarch64-linux-gnu-ar  CACHE FILEPATH "" FORCE)
  set(CMAKE_RANLIB       ${TOOLCHAIN_BIN}/aarch64-linux-gnu-ranlib CACHE FILEPATH "" FORCE)
  message(STATUS "A55: Using cross-compiler from AARCH64_TOOLCHAIN: ${TOOLCHAIN_BIN}")

# Priority 2: Try to find aarch64-linux-gnu-gcc in PATH
else()
  find_program(AARCH64_GCC aarch64-linux-gnu-gcc)
  if(AARCH64_GCC)
    get_filename_component(TOOLCHAIN_BIN ${AARCH64_GCC} DIRECTORY)
    set(CMAKE_C_COMPILER   ${TOOLCHAIN_BIN}/aarch64-linux-gnu-gcc CACHE FILEPATH "" FORCE)
    set(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN}/aarch64-linux-gnu-g++ CACHE FILEPATH "" FORCE)
    set(CMAKE_AR           ${TOOLCHAIN_BIN}/aarch64-linux-gnu-ar  CACHE FILEPATH "" FORCE)
    set(CMAKE_RANLIB       ${TOOLCHAIN_BIN}/aarch64-linux-gnu-ranlib CACHE FILEPATH "" FORCE)
    message(STATUS "A55: Using system cross-compiler: ${AARCH64_GCC}")

  # Priority 3: Try Yocto SDK environment setup
  elseif(DEFINED ENV{YOCTO_SDK_ENV} AND NOT "$ENV{YOCTO_SDK_ENV}" STREQUAL "")
    message(STATUS "A55: Attempting to source Yocto SDK from: $ENV{YOCTO_SDK_ENV}")
    execute_process(
      COMMAND bash -c "source $ENV{YOCTO_SDK_ENV} && which aarch64-poky-linux-gcc || which aarch64-linux-gnu-gcc"
      OUTPUT_VARIABLE YOCTO_GCC
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
    if(YOCTO_GCC)
      get_filename_component(TOOLCHAIN_BIN ${YOCTO_GCC} DIRECTORY)
      # Yocto typically uses aarch64-poky-linux prefix
      if(EXISTS ${TOOLCHAIN_BIN}/aarch64-poky-linux-gcc)
        set(CMAKE_C_COMPILER   ${TOOLCHAIN_BIN}/aarch64-poky-linux-gcc CACHE FILEPATH "" FORCE)
        set(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN}/aarch64-poky-linux-g++ CACHE FILEPATH "" FORCE)
        set(CMAKE_AR           ${TOOLCHAIN_BIN}/aarch64-poky-linux-ar  CACHE FILEPATH "" FORCE)
        set(CMAKE_RANLIB       ${TOOLCHAIN_BIN}/aarch64-poky-linux-ranlib CACHE FILEPATH "" FORCE)
      else()
        set(CMAKE_C_COMPILER   ${TOOLCHAIN_BIN}/aarch64-linux-gnu-gcc CACHE FILEPATH "" FORCE)
        set(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN}/aarch64-linux-gnu-g++ CACHE FILEPATH "" FORCE)
        set(CMAKE_AR           ${TOOLCHAIN_BIN}/aarch64-linux-gnu-ar  CACHE FILEPATH "" FORCE)
        set(CMAKE_RANLIB       ${TOOLCHAIN_BIN}/aarch64-linux-gnu-ranlib CACHE FILEPATH "" FORCE)
      endif()
      message(STATUS "A55: Using Yocto SDK cross-compiler: ${YOCTO_GCC}")
    else()
      message(FATAL_ERROR 
        "A55 cross-compiler not found!\n"
        "  YOCTO_SDK_ENV is set but failed to find compiler after sourcing.\n"
        "  Please check: $ENV{YOCTO_SDK_ENV}\n"
      )
    endif()

  # Priority 4: Error with helpful message
  else()
    message(FATAL_ERROR
      "====================================================================\n"
      "A55 aarch64 cross-compiler not found!\n"
      "====================================================================\n"
      "\n"
      "Please install a cross-compiler using ONE of these methods:\n"
      "\n"
      "Option 1 - Ubuntu/Debian package manager (easiest):\n"
      "  sudo apt update\n"
      "  sudo apt install -y gcc-aarch64-linux-gnu g++-aarch64-linux-gnu\n"
      "\n"
      "Option 2 - Yocto SDK:\n"
      "  Set YOCTO_SDK_ENV to your SDK environment setup script:\n"
      "  export YOCTO_SDK_ENV=/opt/fsl-imx-xwayland/<version>/environment-setup-aarch64-poky-linux\n"
      "  Then re-run: make configure TARGET=a55\n"
      "\n"
      "Option 3 - Custom toolchain:\n"
      "  Set AARCH64_TOOLCHAIN to your toolchain bin directory:\n"
      "  export AARCH64_TOOLCHAIN=/opt/toolchains/aarch64-linux-gnu/bin\n"
      "\n"
      "See docs/CROSS_COMPILER_SETUP.md for more details.\n"
      "====================================================================\n"
    )
  endif()
endif()

# Tune flags (adjust per your CPU/features)
set(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   -O2 -pipe -fPIC")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -pipe -fPIC")

# Prevent finding host libraries during cross-compilation
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
