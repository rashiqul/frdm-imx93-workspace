cmake_minimum_required(VERSION 3.20)
project(imx93_workspace VERSION 0.1.0 LANGUAGES C CXX)

option(BUILD_A55 "Build A55 targets" ON)
option(BUILD_M33 "Build M33 targets" OFF)

# Conan support (find packages only, no toolchain integration to avoid reconfig loops)
if(EXISTS "${CMAKE_SOURCE_DIR}/build/conan")
  list(APPEND CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/build/conan")
endif()

# Global defaults
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Installation directories
include(GNUInstallDirs)

if(BUILD_A55)
  add_subdirectory(apps/a55/hello_app)
endif()

if(BUILD_M33)
  add_subdirectory(apps/m33/blinky)
endif()

# Install any shared headers if you create libs in the future
# install(DIRECTORY libs/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
#         FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp")
