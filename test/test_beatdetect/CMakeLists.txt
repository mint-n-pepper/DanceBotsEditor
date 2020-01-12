project(test-beatdetect)

find_package(Qt5 COMPONENTS Widgets REQUIRED)

set(SOURCES ${CMAKE_SOURCE_DIR}/src/audio_file.cc
            ${CMAKE_SOURCE_DIR}/src/beat_detector.cc)

set(INCLUDE_DIRS  ${CMAKE_SOURCE_DIR})

include_directories(${INCLUDE_DIRS})

set(HEADERS ${CMAKE_SOURCE_DIR}/lib/kissfft/kissfft.hh
            ${CMAKE_SOURCE_DIR}/src/audio_file.h
            ${CMAKE_SOURCE_DIR}/src/beat_detector.h
            ${CMAKE_SOURCE_DIR}/test/test_folder_path.h)

source_group("Header Files" FILES ${HEADERS})

add_executable(${PROJECT_NAME} main.cc ${SOURCES} ${HEADERS})

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
