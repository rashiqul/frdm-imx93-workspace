cmake_minimum_required(VERSION 3.20)
project(imx93_workspace LANGUAGES C CXX)

option(BUILD_A55 "Build A55 targets" ON)
option(BUILD_M33 "Build M33 targets" OFF)

# Conan support (find packages only, no toolchain integration to avoid reconfig loops)
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/build/conan")

# Global defaults
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

if(BUILD_A55)
  add_subdirectory(apps/a55/hello_app)
endif()

if(BUILD_M33)
  add_subdirectory(apps/m33/blinky)
endif()
