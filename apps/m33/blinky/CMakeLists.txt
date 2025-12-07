cmake_minimum_required(VERSION 3.20)
project(blinky_m33 C)

add_executable(blinky_m33
    main.c
)

# You will need a proper linker script/startup files later.
# For now we just compile; linking may fail until you add a linker script.
# Example:
# set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/boards/imx93_m33.ld)
# target_link_options(blinky_m33 PRIVATE "-T${LINKER_SCRIPT}")
