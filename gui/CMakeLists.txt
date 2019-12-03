cmake_minimum_required(VERSION 3.15 FATAL_ERROR)

project(dancebotsGui)

set(CMAKE_CXX_STANDARD 14)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt5 COMPONENTS Core Quick Qml Concurrent Multimedia REQUIRED)

# Telling CMake location of our app .qrc file
qt5_add_resources(APP_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/qml.qrc)

set(SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/../src/AudioFile.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/AudioPlayer.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/BackEnd.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/BeatDetector.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/Primitive.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/PrimitiveList.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/PrimitiveToSignal.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp)

set(INCLUDE_DIRS  ${CMAKE_CURRENT_SOURCE_DIR}/../src
                  ${CMAKE_CURRENT_SOURCE_DIR}/../lib/kissfft)

include_directories(${INCLUDE_DIRS})

set(HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/../src/AudioFile.h
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/AudioPlayer.h
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/Primitive.h
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/Utils.h
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/BackEnd.h
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/BeatDetector.h
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/PrimitiveList.h
            ${CMAKE_CURRENT_SOURCE_DIR}/../src/PrimitiveToSignal.h
            ${CMAKE_CURRENT_SOURCE_DIR}/../lib/kissfft/kissfft.hh)

source_group("Header Files" FILES ${HEADERS})

file(GLOB_RECURSE QMLS ${CMAKE_CURRENT_SOURCE_DIR}/../gui/ *.qml)
source_group("QML Files" FILES ${QMLS})

add_executable(${PROJECT_NAME} WIN32 ${SOURCES} ${APP_RESOURCES} ${HEADERS} ${QMLS})

# copy visual studio user file to binary folder to have
# qt in debug path:
if(WIN32)
  file(COPY ../template.vcxproj.user
       DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
  file(RENAME ${CMAKE_CURRENT_BINARY_DIR}/template.vcxproj.user
              ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.vcxproj.user)
endif()

target_link_libraries(  ${PROJECT_NAME}
                        Qt5::Core
                        Qt5::Quick
                        Qt5::Qml
                        Qt5::Multimedia
                        Qt5::Concurrent
                        lib-qm-dsp
                        lib-qm-vamp
                        mp3lame
                        sndfile
                        tag)
