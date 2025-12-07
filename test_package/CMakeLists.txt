cmake_minimum_required(VERSION 3.20)
project(PackageTest CXX)

find_package(imx93_workspace REQUIRED)

add_executable(test_package test_package.cpp)
