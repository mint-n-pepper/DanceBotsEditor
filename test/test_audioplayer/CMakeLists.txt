project(test-audioplayer)

set(CMAKE_CXX_STANDARD 14)

set(CMAKE_AUTOMOC ON)

find_package(Qt5 COMPONENTS Widgets Multimedia REQUIRED)

set(AUDIOFILE_SRC ${CMAKE_SOURCE_DIR}/src/AudioFile.cpp
                  ${CMAKE_SOURCE_DIR}/src/AudioPlayer.cpp
                  ${CMAKE_CURRENT_SOURCE_DIR}/DummyUI.cpp)

set(HEADERS ${CMAKE_SOURCE_DIR}/src/AudioFile.h
            ${CMAKE_SOURCE_DIR}/src/AudioPlayer.h
            ${CMAKE_CURRENT_SOURCE_DIR}/DummyUI.h
            ${CMAKE_SOURCE_DIR}/test/TestFolderPath.h)

include_directories(${CMAKE_SOURCE_DIR})
source_group("Headers" FILES ${HEADERS})

add_executable(${PROJECT_NAME} main.cpp ${AUDIOFILE_SRC} ${HEADERS})

target_link_libraries(  ${PROJECT_NAME}
                        lib-qm-dsp
                        mp3lame
                        sndfile
                        tag
                        Qt5::Widgets
                        Qt5::Multimedia)

# copy visual studio user file to binary folder to have
# qt in debug path:
if(WIN32)
  configure_file(${CMAKE_SOURCE_DIR}/template.vcxproj.in
			   ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.vcxproj.user
			   @ONLY)
endif()

# group libraries in IDE folder:
set_target_properties(${PROJECT_NAME} PROPERTIES FOLDER manual_tests)
