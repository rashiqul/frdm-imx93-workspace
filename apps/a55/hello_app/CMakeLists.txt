cmake_minimum_required(VERSION 3.20)
project(hello_app_a55 CXX)

add_executable(hello_a55 main.cpp)

# Example Conan deps (fmt/spdlog) if available
# Disabled for cross-compilation to avoid host library conflicts
# TODO: Enable when using Conan for proper cross-compile dependency management
# find_package(fmt QUIET)
# find_package(spdlog QUIET)
# if(fmt_FOUND)
#   target_compile_definitions(hello_a55 PRIVATE USE_FMT=1)
#   target_link_libraries(hello_a55 PRIVATE fmt::fmt)
# endif()
# if(spdlog_FOUND)
#   target_compile_definitions(hello_a55 PRIVATE USE_SPDLOG=1)
#   target_link_libraries(hello_a55 PRIVATE spdlog::spdlog)
# endif()

# Install the executable
install(TARGETS hello_a55
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        COMPONENT a55_apps)
