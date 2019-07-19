cmake_minimum_required(VERSION 3.15 FATAL_ERROR)

project(dancebots_gui)

set(CMAKE_CXX_STANDARD 14)

set(CMAKE_AUTOMOC ON)

add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/lib)
add_subdirectory(test)