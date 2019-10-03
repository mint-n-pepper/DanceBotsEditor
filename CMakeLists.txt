cmake_minimum_required(VERSION 3.15 FATAL_ERROR)

project(dancebots_gui)

set(CMAKE_CXX_STANDARD 14)

set(CMAKE_AUTOMOC ON)

set(USE_FOLDERS ON)

# Prevent overriding the parent project's compiler/linker
# settings on Windows
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/lib)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/test)
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/gui)