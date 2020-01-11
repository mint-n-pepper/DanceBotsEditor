project(test-beatdetect)

find_package(Qt5 COMPONENTS Widgets REQUIRED)

set(SOURCES ${CMAKE_SOURCE_DIR}/src/AudioFile.cpp
            ${CMAKE_SOURCE_DIR}/src/BeatDetector.cpp)

set(INCLUDE_DIRS  ${CMAKE_SOURCE_DIR})

include_directories(${INCLUDE_DIRS})

set(HEADERS ${CMAKE_SOURCE_DIR}/lib/kissfft/kissfft.hh
            ${CMAKE_SOURCE_DIR}/src/AudioFile.h
            ${CMAKE_SOURCE_DIR}/src/BeatDetector.h
            ${CMAKE_SOURCE_DIR}/test/TestFolderPath.h)

source_group("Header Files" FILES ${HEADERS})

add_executable(${PROJECT_NAME} main.cpp ${SOURCES} ${HEADERS})

target_link_libraries(  ${PROJECT_NAME}
                        gtest
                        gmock
                        lib-qm-dsp
                        mp3lame
                        lib-qm-vamp
                        sndfile
                        tag
                        Qt5::Widgets)

# copy visual studio user file to binary folder to have
# qt in debug path:
if(WIN32)
  configure_file(${CMAKE_SOURCE_DIR}/template.vcxproj.in
                 ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.vcxproj.user
                 @ONLY)
endif()

# group libraries in IDE folder:
set_target_properties(${PROJECT_NAME} PROPERTIES FOLDER tests)
