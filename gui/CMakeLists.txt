cmake_minimum_required(VERSION 3.15 FATAL_ERROR)

project(dancebotsEditor)

set(CMAKE_CXX_STANDARD 14)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt5 COMPONENTS Core Quick Qml Concurrent Multimedia Svg REQUIRED)

# Telling CMake location of our app .qrc file
qt5_add_resources(APP_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/qml.qrc)

set(SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/../src/audio_file.cc
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/audio_player.cc
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/backend.cc
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/beat_detector.cc
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/primitive.cc
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/primitive_list.cc
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/primitive_to_signal.cc
            ${CMAKE_CURRENT_SOURCE_DIR}/main.cc)

set(INCLUDE_DIRS  ${CMAKE_SOURCE_DIR}
                  ${CMAKE_CURRENT_SOURCE_DIR}/../lib/kissfft)

include_directories(${INCLUDE_DIRS})

set(HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/../src/audio_file.h
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/audio_player.h
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/primitive.h
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/utils.h
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/backend.h
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/beat_detector.h
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/primitive_list.h
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/primitive_to_signal.h
            ${CMAKE_CURRENT_SOURCE_DIR}/../lib/kissfft/kissfft.hh)

source_group("Header Files" FILES ${HEADERS})

file(GLOB_RECURSE QMLS ${CMAKE_CURRENT_SOURCE_DIR} *.qml)
source_group("QML Files" FILES ${QMLS})

if(WIN32)
  add_executable(${PROJECT_NAME} WIN32
                                 ${SOURCES}
                                 ${APP_RESOURCES}
                                 ${HEADERS}
                                 ${QMLS}
                                 ${CMAKE_CURRENT_SOURCE_DIR}/rc/icon.rc)
else()
  add_executable(${PROJECT_NAME} ${SOURCES} ${APP_RESOURCES} ${HEADERS} ${QMLS})
endif()

# configure visual studio user file to binary folder to have
# qt in debug path, and copy wix source files and icon:
if(WIN32)
  configure_file(${CMAKE_SOURCE_DIR}/template.vcxproj.in
                 ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.vcxproj.user
                 @ONLY)
  configure_file(${CMAKE_SOURCE_DIR}/src/wix/generateWix.py
                 ${CMAKE_CURRENT_BINARY_DIR}/generateWix.py
                 COPYONLY)
  configure_file(${CMAKE_SOURCE_DIR}/src/wix/LICENSE.rtf
                 ${CMAKE_CURRENT_BINARY_DIR}/LICENSE.rtf
                 COPYONLY)                 
  # for use in wix for uninstaller
  configure_file(${CMAKE_SOURCE_DIR}/gui/rc/applogo.ico
                 ${CMAKE_CURRENT_BINARY_DIR}/applogo.ico
                 COPYONLY)                 
endif()

# assign version number
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/lib/cmake")
include(version)
version_from_git()
set(VERSION "${VERSION}")
configure_file(${CMAKE_SOURCE_DIR}/gui/components/AboutText.qml.in ${CMAKE_SOURCE_DIR}/gui/components/AboutText.qml)

# assign keyboard shortcuts
if(APPLE)
  set(CTRL_CMD_KEY "⌘ Cmd")
else()
  set(CTRL_CMD_KEY "Ctrl")
endif()
configure_file(${CMAKE_SOURCE_DIR}/gui/components/AboutText.qml.in ${CMAKE_SOURCE_DIR}/gui/components/AboutText.qml)


target_link_libraries(  ${PROJECT_NAME}
                        Qt5::Core
                        Qt5::Quick
                        Qt5::Qml
                        Qt5::Multimedia
                        Qt5::Concurrent
                        Qt5::Svg
                        lib-qm-dsp
                        lib-qm-vamp
                        mp3lame
                        sndfile
                        tag)
